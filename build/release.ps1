param(
    [string]$Configuration = "Release",
    [string]$RuntimeIdentifier = "win-x64",
    [string]$Channel = "win",
    [switch]$SkipTests,
    [string]$SignParams = $env:VPK_SIGN_PARAMS,
    [string]$SignTemplate = $env:VPK_SIGN_TEMPLATE,
    [string]$AzureTrustedSignFile = $env:VPK_AZURE_TRUSTED_SIGN_FILE,
    [int]$SignParallel = 10
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$supportProject = Join-Path $repoRoot "MEACSSupportTool\MEACSSupportTool.csproj"
$patcherProject = Join-Path $repoRoot "modules\ME_ACS_SQL_Patcher\src\ME_ACS_SQL_Patcher\ME_ACS_SQL_Patcher.csproj"
$solutionPath = Join-Path $repoRoot "ME_ACS_Toolkit.sln"
$publishTempRoot = Join-Path $repoRoot "artifacts\publish-temp"
$supportPublishTemp = Join-Path $publishTempRoot "support-tool"
$patcherPublishTemp = Join-Path $publishTempRoot "sql-patcher"
$outputDir = Join-Path $repoRoot "output"
$portableRoot = Join-Path $outputDir "ME_ACS_Support_Tool"
$portableModulesDir = Join-Path $portableRoot "Modules\SqlPatcher"
$distDir = Join-Path $repoRoot "dist"
$installerDir = Join-Path $distDir "installer"
$feedDir = Join-Path $repoRoot "feed\support-tool"
$releaseNotesPath = Join-Path $repoRoot "artifacts\release-notes-support-tool.md"
$patcherTestsProject = Join-Path $repoRoot "modules\ME_ACS_SQL_Patcher\tests\MagDbPatcher.Tests\MagDbPatcher.Tests.csproj"
$supportIconPath = Join-Path $repoRoot "MEACSSupportTool\Assets\me-acs-support-tool.ico"
$distSetupName = "ME ACS Support Tool Setup.zip"
$distPortableName = "ME ACS Support Tool Portable.zip"

function Get-ProjectVersion([string]$projectPath) {
    $version = (& dotnet msbuild $projectPath --getProperty:Version -nologo).Trim()
    if ([string]::IsNullOrWhiteSpace($version)) {
        throw "Could not read version from $projectPath"
    }

    return [string]$version
}

function Assert-AppNotRunning([string[]]$processNames) {
    $running = @(Get-Process -Name $processNames -ErrorAction SilentlyContinue)
    if ($running.Count -eq 0) {
        return
    }

    $details = $running |
        Sort-Object ProcessName, Id |
        ForEach-Object { "$($_.ProcessName) (PID $($_.Id))" }

    throw "Close the running app before packaging: $([string]::Join(', ', $details))."
}

function Publish-Project([string]$projectPath, [string]$publishDir) {
    if (Test-Path $publishDir) {
        Remove-Item -Recurse -Force $publishDir
    }

    dotnet publish $projectPath `
        -c $Configuration `
        -o $publishDir `
        -r $RuntimeIdentifier `
        --self-contained true `
        "-p:PublishSingleFile=true" `
        "-p:EnableCompressionInSingleFile=true" `
        "-p:PublishTrimmed=false" `
        "-p:DebugType=None" `
        "-p:DebugSymbols=false" `
        "-p:SatelliteResourceLanguages=en" | Out-Host

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet publish failed for $projectPath"
    }
}

function Test-HasText([string]$value) {
    return -not [string]::IsNullOrWhiteSpace($value)
}

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

    return [pscustomobject][ordered]@{
        Version = $latestVersion
        Label = "$latestVersion | $scriptCount scripts | $($lastUpdatedUtc.AddHours(8).ToString('dd MMM yyyy HH:mm')) MYT"
        Summary = "$versionCount version(s), $patchCount patch link(s), $scriptCount script(s)"
        Hash = $catalogHash
    }
}

function Write-PatchCatalogMetadata([string]$modulePublishDir) {
    $patchCatalog = Get-PatchCatalogMetadata (Join-Path $modulePublishDir "patches")
    [ordered]@{
        version = $patchCatalog.Version
        label = $patchCatalog.Label
        summary = $patchCatalog.Summary
        hash = $patchCatalog.Hash
    } | ConvertTo-Json | Set-Content (Join-Path $modulePublishDir "patch-catalog.json") -Encoding UTF8

    return $patchCatalog
}

$supportVersion = Get-ProjectVersion $supportProject

$signModeCount = @(
    (Test-HasText $SignParams),
    (Test-HasText $SignTemplate),
    (Test-HasText $AzureTrustedSignFile)
) | Where-Object { $_ } | Measure-Object | Select-Object -ExpandProperty Count

if ($signModeCount -gt 1) {
    throw "Specify only one signing mode: -SignParams, -SignTemplate, or -AzureTrustedSignFile."
}

if ((Test-HasText $AzureTrustedSignFile) -and -not (Test-Path $AzureTrustedSignFile)) {
    throw "Azure Trusted Signing metadata file not found: $AzureTrustedSignFile"
}

if ($SignParallel -lt 1) {
    throw "-SignParallel must be 1 or greater."
}

Write-Host ""
Write-Host "Building ME ACS Support Tool v$supportVersion"
Write-Host "==============================================="

Assert-AppNotRunning @("MEACSSupportTool", "ME_ACS_SQL_Patcher")

if (-not $SkipTests) {
    Write-Host "Running SQL patcher tests..."
    dotnet test $patcherTestsProject -c $Configuration | Out-Host
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

dotnet build $solutionPath -c $Configuration | Out-Host
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

dotnet tool restore | Out-Host
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

if (Test-Path $outputDir) {
    Remove-Item -Recurse -Force $outputDir
}

if (Test-Path $distDir) {
    Remove-Item -Recurse -Force $distDir
}

if (Test-Path $feedDir) {
    New-Item -ItemType Directory -Path $feedDir -Force | Out-Null
} else {
    New-Item -ItemType Directory -Path $feedDir -Force | Out-Null
}

New-Item -ItemType Directory -Path $portableRoot -Force | Out-Null
New-Item -ItemType Directory -Path $portableModulesDir -Force | Out-Null
New-Item -ItemType Directory -Path $installerDir -Force | Out-Null

Publish-Project $supportProject $supportPublishTemp
Publish-Project $patcherProject $patcherPublishTemp
$patchCatalog = Write-PatchCatalogMetadata $patcherPublishTemp

Copy-Item -Path (Join-Path $supportPublishTemp "*") -Destination $portableRoot -Recurse -Force
Copy-Item -Path (Join-Path $patcherPublishTemp "*") -Destination $portableModulesDir -Recurse -Force

$buildDateFile = Join-Path $portableRoot "build-date.txt"
$buildDate = if (Test-Path $buildDateFile) {
    (Get-Content $buildDateFile -Raw).Trim()
} else {
    [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
}

$toolkitManifest = [ordered]@{
    supportTool = @{
        version = $supportVersion
        executable = "MEACSSupportTool.exe"
        buildDate = $buildDate
    }
    modules = @(
        @{
            id = "sql-patcher"
            version = $supportVersion
            displayName = "SQL Patcher"
            kind = "extension"
            executable = "Modules/SqlPatcher/ME_ACS_SQL_Patcher.exe"
            patchCatalogLabel = $patchCatalog.Label
            patchCatalogSummary = $patchCatalog.Summary
        }
    )
}
$toolkitManifest | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $portableRoot "toolkit-manifest.json") -Encoding UTF8

$releaseNotes = @"
Internal refresh for ME ACS Support Tool $supportVersion.
Bundled SQL patch catalog: $($patchCatalog.Label)
Catalog summary: $($patchCatalog.Summary)
"@.Trim()

"# ME ACS Support Tool $supportVersion`n`n$releaseNotes" | Set-Content $releaseNotesPath -Encoding UTF8

$vpkArgs = @(
    "pack",
    "--packId", "MEACSSupportTool",
    "--packVersion", $supportVersion,
    "--packDir", $portableRoot,
    "--mainExe", "MEACSSupportTool.exe",
    "--packTitle", "ME ACS Support Tool",
    "--packAuthors", "Magnet Security",
    "--outputDir", $installerDir,
    "--runtime", $RuntimeIdentifier,
    "--channel", $Channel,
    "--releaseNotes", $releaseNotesPath,
    "--icon", $supportIconPath,
    "--delta", "None",
    "--shortcuts", "Desktop,StartMenu"
)

if (Test-HasText $AzureTrustedSignFile) {
    Write-Host "Using Azure Trusted Signing metadata from $AzureTrustedSignFile"
    $vpkArgs += @("--azureTrustedSignFile", $AzureTrustedSignFile)
} elseif (Test-HasText $SignTemplate) {
    Write-Host "Using custom signing template."
    $vpkArgs += @("--signTemplate", $SignTemplate)
} elseif (Test-HasText $SignParams) {
    Write-Host "Using signtool-compatible signing parameters."
    $vpkArgs += @("--signParams", $SignParams, "--signParallel", "$SignParallel")
} else {
    Write-Host "Packaging without code signing."
}

& dotnet tool run vpk -- @vpkArgs | Out-Host
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$setupExe = Join-Path $installerDir "MEACSSupportTool-win-Setup.exe"
if (Test-Path $setupExe) {
    $setupStagingDir = Join-Path $repoRoot "artifacts\setup-handoff-staging"
    if (Test-Path $setupStagingDir) {
        Remove-Item -Recurse -Force $setupStagingDir
    }

    New-Item -ItemType Directory -Path $setupStagingDir -Force | Out-Null
    Copy-Item $setupExe (Join-Path $setupStagingDir "ME ACS Support Tool Setup.exe") -Force
    Compress-Archive -Path (Join-Path $setupStagingDir "*") -DestinationPath (Join-Path $distDir $distSetupName) -Force
    Remove-Item -Recurse -Force $setupStagingDir
}

$portablePackage = Join-Path $installerDir "MEACSSupportTool-win-Portable.zip"
if (Test-Path $portablePackage) {
    Copy-Item $portablePackage (Join-Path $distDir $distPortableName) -Force
}

$installerFiles = Get-ChildItem -Path $installerDir -File
if (-not $installerFiles) {
    throw "No installer artifacts found in $installerDir."
}
foreach ($installerFile in $installerFiles) {
    Copy-Item $installerFile.FullName $feedDir -Force
}
Remove-Item -Recurse -Force $installerDir

$feedInstallerName = "MEACSSupportTool-win-Setup-$($buildDate.Replace(':','').Replace('-','')).exe"
$feedInstallerPath = Join-Path $feedDir $feedInstallerName
$defaultFeedInstallerPath = Join-Path $feedDir "MEACSSupportTool-win-Setup.exe"
if (Test-Path $defaultFeedInstallerPath) {
    Move-Item -Path $defaultFeedInstallerPath -Destination $feedInstallerPath -Force
}

$installerSha256 = (Get-FileHash -Path $feedInstallerPath -Algorithm SHA256).Hash.ToLowerInvariant()
$latestEntry = [ordered]@{
    version = $supportVersion
    buildDate = $buildDate
    installerName = $feedInstallerName
    installerSha256 = $installerSha256
    patchCatalogVersion = $patchCatalog.Version
    patchCatalogLabel = $patchCatalog.Label
    patchCatalogSummary = $patchCatalog.Summary
    patchCatalogHash = $patchCatalog.Hash
    releaseNotes = $releaseNotes
}
$latestEntry | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $feedDir "latest.json") -Encoding UTF8

Write-Host ""
Write-Host "Release complete"
Write-Host "  Output folder : $portableRoot"
Write-Host "  Dist setup    : $(Join-Path $distDir $distSetupName)"
Write-Host "  Dist portable : $(Join-Path $distDir $distPortableName)"
Write-Host "  Feed folder   : $feedDir"
Write-Host ""
