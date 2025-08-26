# ================================
# Windows 11 Enterprise Upgrade Script
# ================================

$dir = "C:\Win11Upgrade"
$setupPath = Join-Path $dir "setup.exe"
$setupPrepPath = Join-Path $dir "sources\setupprep.exe"
$logPath = "C:\Install\WinSetup.log"

# Ensure directory exists
if (-not (Test-Path $dir)) {
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
}

# Check if setup.exe exists
if (Test-Path $setupPath) {
    Write-Host "Found setup.exe at $setupPath. Starting upgrade..." -ForegroundColor Green
    Start-Process -FilePath $setupPath -ArgumentList "/auto upgrade /quiet /noreboot /dynamicupdate disable /copylogs $logPath" -Wait
}
elseif (Test-Path $setupPrepPath) {
    Write-Host "setup.exe not found. Using setupprep.exe..." -ForegroundColor Yellow
    Start-Process -FilePath $setupPrepPath -ArgumentList "/product server /auto upgrade /quiet /noreboot /dynamicupdate disable /copylogs $logPath" -Wait
}
else {
    Write-Host "No setup.exe or setupprep.exe found in $dir. Aborting!" -ForegroundColor Red
    exit 1
}

Write-Host "Upgrade process completed. Check logs at $logPath" -ForegroundColor Cyan
