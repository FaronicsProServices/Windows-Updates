# ========================================
# Windows 11 Enterprise Upgrade Script
# Works with C:\Win11Upgrade\setup.exe
# ========================================

$dir = 'C:\Win11Upgrade'
$setupPath = Join-Path $dir "setup.exe"
$logPath = "C:\Install\WinSetup.log"

# Make sure log directory exists
$logDir = Split-Path $logPath -Parent
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

Write-Host "Starting Windows 11 Enterprise Upgrade..." -ForegroundColor Cyan

# Check for setup.exe
if (Test-Path $setupPath) {
    Write-Host "Found setup.exe in $dir. Launching upgrade..." -ForegroundColor Green
    Start-Process -FilePath $setupPath `
        -ArgumentList "/auto upgrade /quiet /noreboot /dynamicupdate disable /copylogs $logPath" `
        -Wait
    Write-Host "Upgrade process completed. Logs are saved at $logPath" -ForegroundColor Cyan
}
else {
    Write-Host "ERROR: setup.exe not found in $dir" -ForegroundColor Red
    exit 1
}
