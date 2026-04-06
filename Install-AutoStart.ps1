<#
.SYNOPSIS
    Sets up the ME ACS Support Tool update server to auto-start on login.
    Uses Python (already installed). No Administrator required.

.USAGE
    Right click -> Run with PowerShell
#>

param(
    [switch]$NoPause
)

$ErrorActionPreference = "Stop"

$Port = 39000
$ServePy = Join-Path $PSScriptRoot "serve.py"
$FeedPath = Join-Path $PSScriptRoot "feed\support-tool"
$StartupDir = [Environment]::GetFolderPath("Startup")
$ShortcutPath = Join-Path $StartupDir "ME ACS Support Tool Update Server.lnk"
$LegacyShortcutPath = Join-Path $StartupDir "MagEtegra Update Server.lnk"

if (-not (Test-Path $ServePy)) {
    Write-Host "ERROR: serve.py not found." -ForegroundColor Red
    pause
    exit 1
}

if (-not (Test-Path $FeedPath)) {
    Write-Host "ERROR: Support tool feed folder not found at: $FeedPath" -ForegroundColor Red
    pause
    exit 1
}

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$python = if ($pythonCmd) { $pythonCmd.Source } else { $null }
if (-not $python) {
    Write-Host "ERROR: Python not found. Install Python from python.org." -ForegroundColor Red
    pause
    exit 1
}

$existingServers = Get-CimInstance Win32_Process |
    Where-Object {
        $_.CommandLine -and
        $_.CommandLine -match 'serve\.py' -and
        $_.CommandLine -match '39000'
    }

foreach ($server in $existingServers) {
    try {
        Stop-Process -Id $server.ProcessId -Force -ErrorAction Stop
        Write-Host "Stopped previous feed server process $($server.ProcessId)."
    }
    catch {
        Write-Host "Could not stop old feed server process $($server.ProcessId): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if (Test-Path $LegacyShortcutPath) {
    Remove-Item $LegacyShortcutPath -Force
    Write-Host "Removed legacy startup shortcut."
}

Write-Host "Registering support tool auto-start..."
$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = "pythonw.exe"
$shortcut.Arguments = "`"$ServePy`" $Port"
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.Description = "ME ACS Support Tool update feed server"
$shortcut.Save()
Write-Host "  Auto-start registered."

Write-Host "Starting support tool feed server now..."
Start-Process "pythonw.exe" -ArgumentList "`"$ServePy`" $Port" -WorkingDirectory $PSScriptRoot
Start-Sleep -Seconds 2

$localIp = (Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.*" } |
    Select-Object -First 1).IPAddress

Write-Host ""
Write-Host "============================================"
Write-Host "  Done! Support tool feed server is running."
Write-Host "============================================"
Write-Host ""
Write-Host "  Set this URL in Toolkit Updates -> Set Feed URL"
Write-Host "  on support-team PCs:"
Write-Host ""
Write-Host "  http://${localIp}:${Port}" -ForegroundColor Green
Write-Host ""
Write-Host "  Feed root:"
Write-Host "  $FeedPath"
Write-Host ""
Write-Host "  Auto-starts on every login. No admin needed."
Write-Host "============================================"
if (-not $NoPause) {
    pause
}
