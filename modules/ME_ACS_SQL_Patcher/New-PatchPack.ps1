param(
    [Parameter(Mandatory = $true)]
    [string]$PatchesFolder,

    [Parameter(Mandatory = $true)]
    [string]$PackVersion,

    [string]$OutFile = "MagPatchPack.zip",

    [string]$Notes = ""
)

if (!(Test-Path -LiteralPath $PatchesFolder)) {
    throw "Patches folder not found: $PatchesFolder"
}

$patchesFull = (Resolve-Path -LiteralPath $PatchesFolder).Path
$outFull = (Resolve-Path -LiteralPath (Split-Path -Parent $OutFile) -ErrorAction SilentlyContinue)

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("MagPatchPack_" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot | Out-Null

try {
    $manifest = @{
        schemaVersion = 1
        packVersion   = $PackVersion
        releasedAt    = (Get-Date).ToString("o")
        minAppVersion = "1.0.0"
        notes         = $Notes
        contentRoot   = "patches"
    }

    $manifestPath = Join-Path $tempRoot "patch-pack.json"
    ($manifest | ConvertTo-Json -Depth 10) | Out-File -FilePath $manifestPath -Encoding utf8

    $destPatches = Join-Path $tempRoot "patches"
    Copy-Item -Recurse -Force -LiteralPath $patchesFull -Destination $destPatches

    if (Test-Path -LiteralPath $OutFile) {
        Remove-Item -Force -LiteralPath $OutFile
    }

    Compress-Archive -Path (Join-Path $tempRoot "*") -DestinationPath $OutFile -Force
    Write-Host "Created patch pack:"
    Write-Host (Resolve-Path -LiteralPath $OutFile).Path
}
finally {
    try { Remove-Item -Recurse -Force -LiteralPath $tempRoot } catch { }
}
