param(
    [string]$Configuration = "Release",
    [string]$RuntimeIdentifier = "win-x64"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$supportProject = Join-Path $repoRoot "MEACSSupportTool\MEACSSupportTool.csproj"
$patcherProject = Join-Path $repoRoot "modules\ME_ACS_SQL_Patcher\src\ME_ACS_SQL_Patcher\ME_ACS_SQL_Patcher.csproj"
$publishTempRoot = Join-Path $repoRoot "artifacts\publish-temp"
$supportPublishTemp = Join-Path $publishTempRoot "support-tool"
$patcherPublishTemp = Join-Path $publishTempRoot "sql-patcher"
$outputDir = Join-Path $repoRoot "output"
$portableRoot = Join-Path $outputDir "ME_ACS_Support_Tool"
$portableModulesDir = Join-Path $portableRoot "Modules\SqlPatcher"
$distDir = Join-Path $repoRoot "dist"
$portableZipName = "ME ACS Support Tool Portable.zip"
$portableFolderName = "ME ACS Support Tool Portable"

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

Write-Host ""
Write-Host "Packaging ME ACS Support Toolkit"
Write-Host "================================"

if (Test-Path $outputDir) {
    Remove-Item -Recurse -Force $outputDir
}

if (Test-Path $distDir) {
    Remove-Item -Recurse -Force $distDir
}

New-Item -ItemType Directory -Path $portableRoot -Force | Out-Null
New-Item -ItemType Directory -Path $portableModulesDir -Force | Out-Null
New-Item -ItemType Directory -Path $distDir -Force | Out-Null

Publish-Project $supportProject $supportPublishTemp
Publish-Project $patcherProject $patcherPublishTemp
$patchCatalog = Write-PatchCatalogMetadata $patcherPublishTemp

Copy-Item -Path (Join-Path $supportPublishTemp "*") -Destination $portableRoot -Recurse -Force
Copy-Item -Path (Join-Path $patcherPublishTemp "*") -Destination $portableModulesDir -Recurse -Force

$toolkitManifest = [ordered]@{
    supportTool = @{
        executable = "MEACSSupportTool.exe"
    }
    modules = @(
        @{
            id = "sql-patcher"
            displayName = "SQL Patcher"
            kind = "extension"
            version = $patchCatalog.Version
            executable = "Modules/SqlPatcher/ME_ACS_SQL_Patcher.exe"
            patchCatalogLabel = $patchCatalog.Label
            patchCatalogSummary = $patchCatalog.Summary
        }
    )
}
$toolkitManifest | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $portableRoot "toolkit-manifest.json") -Encoding UTF8

$stagingDir = Join-Path $repoRoot "artifacts\handoff-staging"
if (Test-Path $stagingDir) {
    Remove-Item -Recurse -Force $stagingDir
}

New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null
$portableStaging = Join-Path $stagingDir $portableFolderName
New-Item -ItemType Directory -Path $portableStaging -Force | Out-Null
Copy-Item -Path (Join-Path $portableRoot "*") -Destination $portableStaging -Recurse -Force

$zipPath = Join-Path $distDir $portableZipName
Compress-Archive -Path (Join-Path $stagingDir "*") -DestinationPath $zipPath -Force
Remove-Item -Recurse -Force $stagingDir

Write-Host ""
Write-Host "Portable toolkit package ready:"
Write-Host "  Output folder : $portableRoot"
Write-Host "  Zip file      : $zipPath"
Write-Host ""
