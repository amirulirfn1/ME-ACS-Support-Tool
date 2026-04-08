param(
    [string]$Configuration     = "Release",
    [string]$RuntimeIdentifier = "win-x64",
    [string]$Channel           = "win",
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"

$repoRoot     = $PSScriptRoot
$projectPath  = Join-Path $repoRoot "src\ME_ACS_SQL_Patcher\ME_ACS_SQL_Patcher.csproj"
$solutionPath = Join-Path $repoRoot "ME_ACS_SQL_Patcher.sln"
$publishTemp  = Join-Path $repoRoot "artifacts\publish-temp"
$outputDir    = Join-Path $repoRoot "output"
$distDir      = Join-Path $repoRoot "dist"
$installerDir = Join-Path $distDir  "installer"
$feedDir      = Join-Path $repoRoot "feed"
$iconPath     = Join-Path $repoRoot "src\ME_ACS_SQL_Patcher\Assets\me-acs-patcher.ico"

# Read version from csproj, resolving $(PropName) via parent Directory.Build.props if needed
[xml]$proj = Get-Content $projectPath
$version = @($proj.Project.PropertyGroup | Where-Object { $_.Version } | Select-Object -First 1)[0].Version
if ([string]::IsNullOrWhiteSpace($version)) { throw "Could not read version from $projectPath" }

if ($version -match '^\$\((\w+)\)$') {
    $propName = $Matches[1]
    $searchDir = Split-Path -Parent $projectPath
    $root = [System.IO.Path]::GetPathRoot($searchDir)
    while ($searchDir -ne $root) {
        $propsFile = Join-Path $searchDir "Directory.Build.props"
        if (Test-Path $propsFile) {
            [xml]$props = Get-Content $propsFile
            $resolved = @($props.Project.PropertyGroup | ForEach-Object { $_.$propName } | Where-Object { $_ }) | Select-Object -First 1
            if (-not [string]::IsNullOrWhiteSpace($resolved)) { $version = $resolved; break }
        }
        $searchDir = Split-Path -Parent $searchDir
    }
}
if ([string]::IsNullOrWhiteSpace($version) -or $version -match '^\$\(') { throw "Could not resolve version '$version' from $projectPath" }

function Get-PatchCatalogMetadata([string]$patchesRoot) {
    if (-not (Test-Path $patchesRoot)) {
        throw "Patch catalog folder not found: $patchesRoot"
    }

    $normalizedRoot = [System.IO.Path]::GetFullPath($patchesRoot)
    if (-not $normalizedRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $normalizedRoot += [System.IO.Path]::DirectorySeparatorChar
    }

    $patchFiles = @(Get-ChildItem -Path $patchesRoot -Recurse -File | Sort-Object FullName)
    $scriptCount = @($patchFiles | Where-Object { $_.Extension -ieq ".sql" }).Count
    $versionCount = 0
    $patchCount = 0
    $latestVersion = "Unknown"

    $versionsJsonPath = Join-Path $patchesRoot "versions.json"
    if (Test-Path $versionsJsonPath) {
        try {
            $catalog = Get-Content $versionsJsonPath -Raw | ConvertFrom-Json
            $versions = @($catalog.versions)
            $patches = @($catalog.patches)
            $versionCount = $versions.Count
            $patchCount = $patches.Count

            $orderedVersions = @($versions | Sort-Object `
                @{ Expression = { if ($null -eq $_.order) { 0 } else { [int]$_.order } } }, `
                @{ Expression = { [string]$_.id } })
            if ($orderedVersions.Count -gt 0) {
                $latestVersion = [string]$orderedVersions[-1].id
            }
        } catch {
        }
    }

    if ($versionCount -eq 0) {
        $versionCount = @(Get-ChildItem -Path $patchesRoot -Directory -ErrorAction SilentlyContinue).Count
    }

    if ([string]::IsNullOrWhiteSpace($latestVersion) -or $latestVersion -eq "Unknown") {
        $latestVersion = [string](@(Get-ChildItem -Path $patchesRoot -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name |
            Select-Object -Last 1 -ExpandProperty Name))
        if ([string]::IsNullOrWhiteSpace($latestVersion)) {
            $latestVersion = "Unknown"
        }
    }

    $fingerprintLines = New-Object 'System.Collections.Generic.List[string]'
    foreach ($file in $patchFiles) {
        $relative = $file.FullName.Substring($normalizedRoot.Length).Replace('\', '/').ToLowerInvariant()
        $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        [void]$fingerprintLines.Add("$relative|$hash")
    }

    $fingerprintBytes = [System.Text.Encoding]::UTF8.GetBytes([string]::Join("`n", $fingerprintLines))
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $catalogHash = ([System.BitConverter]::ToString($sha256.ComputeHash($fingerprintBytes))).Replace("-", "").ToLowerInvariant()
    } finally {
        $sha256.Dispose()
    }

    $lastUpdatedUtc = if ($patchFiles.Count -gt 0) {
        [DateTime]($patchFiles | Measure-Object -Property LastWriteTimeUtc -Maximum).Maximum
    } else {
        [DateTime]::UtcNow
    }

    $catalogLabel = "$latestVersion | $scriptCount scripts | $($lastUpdatedUtc.AddHours(8).ToString('dd MMM yyyy HH:mm')) MYT"
    $catalogSummary = "$versionCount version(s), $patchCount patch link(s), $scriptCount script(s)"

    return [pscustomobject][ordered]@{
        Version = $latestVersion
        Label = $catalogLabel
        Summary = $catalogSummary
        Hash = $catalogHash
        ScriptCount = $scriptCount
        VersionCount = $versionCount
        PatchCount = $patchCount
    }
}

function Get-ReleaseNotesText([string]$repoRoot, [string]$version, $patchCatalog) {
    $manualReleaseNotesPath = Join-Path $repoRoot "release-notes.txt"
    if (Test-Path $manualReleaseNotesPath) {
        $manualNotes = (Get-Content $manualReleaseNotesPath -Raw).Trim()
        if (-not [string]::IsNullOrWhiteSpace($manualNotes)) {
            return $manualNotes
        }
    }

    return @"
Internal refresh for ME_ACS SQL Patcher $version.
Bundled patch catalog: $($patchCatalog.Label)
Catalog summary: $($patchCatalog.Summary)
"@.Trim()
}

Write-Host ""
Write-Host "Building ME_ACS SQL Patcher v$version"
Write-Host "======================================"

# Guard: app must not be running
$running = Get-Process ME_ACS_SQL_Patcher -ErrorAction SilentlyContinue
if ($running) {
    $pids = ($running | Select-Object -ExpandProperty Id) -join ", "
    throw "App is still running (PID: $pids). Close it first."
}

# --- TESTS ---
if (-not $SkipTests) {
    Write-Host "Running tests..."
    dotnet test $solutionPath | Out-Host
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# --- TOOLS ---
Write-Host "Restoring tools..."
dotnet tool restore | Out-Host
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# --- BUILD + PUBLISH ---
Write-Host "Cleaning previous build..."
dotnet clean $projectPath -c $Configuration | Out-Host
dotnet clean $projectPath -c $Configuration -r $RuntimeIdentifier | Out-Host

Write-Host "Publishing..."
if (Test-Path $publishTemp) { Remove-Item -Recurse -Force $publishTemp }
if (Test-Path (Join-Path $repoRoot "publish")) { Remove-Item -Recurse -Force (Join-Path $repoRoot "publish") }

dotnet publish $projectPath `
    -c $Configuration `
    -o $publishTemp `
    -r $RuntimeIdentifier `
    --self-contained true `
    "-p:PublishSingleFile=true" `
    "-p:EnableCompressionInSingleFile=true" `
    "-p:PublishTrimmed=false" `
    "-p:DebugType=None" `
    "-p:DebugSymbols=false" `
    "-p:SatelliteResourceLanguages=en" | Out-Host
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Copy to output/ (persistent portable folder, used by vpk)
Write-Host "Preparing output folder..."
if (Test-Path $outputDir) { Remove-Item -Recurse -Force $outputDir }
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
Copy-Item -Path (Join-Path $publishTemp "*") -Destination $outputDir -Recurse -Force

$patchCatalog = Get-PatchCatalogMetadata (Join-Path $outputDir "patches")
[ordered]@{
    version = $patchCatalog.Version
    label   = $patchCatalog.Label
    summary = $patchCatalog.Summary
    hash    = $patchCatalog.Hash
} | ConvertTo-Json | Set-Content (Join-Path $outputDir "patch-catalog.json") -Encoding UTF8

# --- DIST ---
if (Test-Path $distDir) { Remove-Item -Recurse -Force $distDir }
New-Item -ItemType Directory -Path $distDir | Out-Null

# Strip .pdb from the zip source
Get-ChildItem -Path $publishTemp -Filter *.pdb -Recurse -File | Remove-Item -Force -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $publishTemp

# --- VPK PACK ---
Write-Host "Packing Velopack installer..."
New-Item -ItemType Directory -Path $installerDir -Force | Out-Null

$releaseNotesPath = Join-Path $repoRoot "artifacts\release-notes-$version.md"
New-Item -ItemType Directory -Path (Split-Path -Parent $releaseNotesPath) -Force | Out-Null
$releaseNotesText = Get-ReleaseNotesText $repoRoot $version $patchCatalog
"# ME_ACS SQL Patcher $version`n`n$releaseNotesText" | Set-Content $releaseNotesPath -Encoding UTF8

dotnet tool run vpk -- pack `
    --packId    "ME_ACS_SQL_Patcher" `
    --packVersion $version `
    --packDir   $outputDir `
    --mainExe   "ME_ACS_SQL_Patcher.exe" `
    --packTitle "ME_ACS SQL Patcher" `
    --packAuthors "Magnet Security" `
    --outputDir $installerDir `
    --runtime   $RuntimeIdentifier `
    --channel   $Channel `
    --releaseNotes $releaseNotesPath `
    --icon      $iconPath `
    --delta     None `
    --shortcuts "Desktop,StartMenuRoot" | Out-Host
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# --- HANDOFF ZIP ---
Write-Host "Building handoff zip..."
$stagingDir = Join-Path $repoRoot "artifacts\handoff-staging"
if (Test-Path $stagingDir) { Remove-Item -Recurse -Force $stagingDir }
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

@"
ME ACS SQL Patcher v$version
================================

OPTION A: Install (Recommended)
  1. Run ME_ACS_SQL_Patcher-win-Setup.exe
  2. A desktop shortcut will be created automatically

OPTION B: Portable (No Install)
  1. Open the portable\ folder
  2. Double-click ME_ACS_SQL_Patcher.exe

Requirements: Windows 10 or 11, 64-bit

------------------------------------------------------------
UPDATING
  New app version  : Run the new Setup.exe over the old one.
  New SQL patches  : Open the app -> Import Patches -> select MagPatchPack-*.zip
Your data lives in: %LOCALAPPDATA%\MagDbPatcher\
------------------------------------------------------------
"@ | Set-Content (Join-Path $stagingDir "README.txt") -Encoding ASCII

$setupExe = Join-Path $installerDir "ME_ACS_SQL_Patcher-win-Setup.exe"
if (Test-Path $setupExe) { Copy-Item $setupExe (Join-Path $stagingDir "ME_ACS_SQL_Patcher-win-Setup.exe") }

$portableStaging = Join-Path $stagingDir "portable"
New-Item -ItemType Directory -Path $portableStaging -Force | Out-Null
Copy-Item -Path (Join-Path $outputDir "*") -Destination $portableStaging -Recurse -Force

$handoffZip = Join-Path $distDir "ME_ACS_SQL_Patcher-$version.zip"
Compress-Archive -Path (Join-Path $stagingDir "*") -DestinationPath $handoffZip -Force
Remove-Item -Recurse -Force $stagingDir

# --- PUBLISH TO FEED ---
Write-Host "Publishing to update feed..."
New-Item -ItemType Directory -Path $feedDir -Force | Out-Null
Get-ChildItem -Path $feedDir -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -ne '.gitkeep' -and
        $_.Name -ne 'history.json' -and
        $_.Name -notlike 'ME_ACS_SQL_Patcher-win-Setup-*.exe'
    } |
    Remove-Item -Force

$installerFiles = Get-ChildItem -Path $installerDir -File
if (-not $installerFiles) { throw "No installer artifacts found in $installerDir." }
foreach ($f in $installerFiles) { Copy-Item $f.FullName $feedDir -Force }
Remove-Item -Recurse -Force $installerDir

$buildDateFile = Join-Path $outputDir "build-date.txt"
$buildDate = if (Test-Path $buildDateFile) {
    (Get-Content $buildDateFile -Raw).Trim()
} else {
    [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
}

$feedInstallerName = "ME_ACS_SQL_Patcher-win-Setup-$($buildDate.Replace(':','').Replace('-','')).exe"
$feedInstallerPath = Join-Path $feedDir $feedInstallerName
$defaultFeedInstallerPath = Join-Path $feedDir "ME_ACS_SQL_Patcher-win-Setup.exe"
if (Test-Path $defaultFeedInstallerPath) {
    Move-Item -Path $defaultFeedInstallerPath -Destination $feedInstallerPath -Force
}

$installerSha256 = (Get-FileHash -Path $feedInstallerPath -Algorithm SHA256).Hash.ToLowerInvariant()
$latestEntry = [ordered]@{
    version         = $version
    buildDate       = $buildDate
    installerName   = $feedInstallerName
    installerSha256 = $installerSha256
    patchCatalogVersion = $patchCatalog.Version
    patchCatalogLabel   = $patchCatalog.Label
    patchCatalogSummary = $patchCatalog.Summary
    patchCatalogHash    = $patchCatalog.Hash
    releaseNotes        = $releaseNotesText
}
$latestEntry | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $feedDir "latest.json") -Encoding UTF8

$historyPath = Join-Path $feedDir "history.json"
$history = @()
if (Test-Path $historyPath) {
    try {
        $parsedHistory = Get-Content $historyPath -Raw | ConvertFrom-Json
        if ($parsedHistory -is [System.Array]) {
            $history = @($parsedHistory)
        } elseif ($null -ne $parsedHistory) {
            $history = @($parsedHistory)
        }
    } catch {
        $history = @()
    }
}

$history = @($latestEntry) + @($history | Where-Object { $_.installerName -ne $feedInstallerName })
$history = @($history | Select-Object -First 3)
$history | ConvertTo-Json -Depth 4 | Set-Content $historyPath -Encoding UTF8

$keptInstallerNames = @($history | ForEach-Object { $_.installerName })
Get-ChildItem -Path $feedDir -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like 'ME_ACS_SQL_Patcher-win-Setup-*.exe' -and
        ($keptInstallerNames -notcontains $_.Name)
    } |
    Remove-Item -Force

# --- START / RESTART SERVE.PY ---
Write-Host "Starting update server..."
$servePy = Join-Path $repoRoot "serve.py"
# Kill any existing instance on the same port
Get-CimInstance Win32_Process -Filter "name = 'pythonw.exe'" |
    Where-Object { $_.CommandLine -like "*serve.py*" } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Milliseconds 500
Start-Process "pythonw.exe" -ArgumentList "`"$servePy`" 39000" -WorkingDirectory $repoRoot

# Detect IP for display
$localIP = try {
    $s = [System.Net.Sockets.Socket]::new([System.Net.Sockets.AddressFamily]::InterNetwork,
        [System.Net.Sockets.SocketType]::Dgram, [System.Net.Sockets.ProtocolType]::Udp)
    $s.Connect("8.8.8.8", 80)
    $s.LocalEndPoint.Address.ToString()
} catch { "localhost" } finally { if ($s) { $s.Close() } }

Write-Host ""
Write-Host "======================================"
Write-Host "  Release complete  (v$version)"
Write-Host "======================================"
Write-Host ""
Write-Host "  Handoff zip : $handoffZip"
Write-Host "  Feed folder : $feedDir"
Write-Host "  Build date  : $buildDate"
Write-Host "  Patch catalog : $($patchCatalog.Label)"
Write-Host "  Feed retention : last 3 setup installers"
Write-Host ""
Write-Host "  Update server : http://${localIP}:39000" -ForegroundColor Green
Write-Host "  (server started automatically)"
Write-Host ""
