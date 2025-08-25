<#
.SYNOPSIS
    Windows 10 -> Windows 11 Upgrade (scan only)
    Supports UNC and Local paths
#>

param (
    [string]$SourcePath = "C:\Win11Upgrade"  # Change to your UNC or local path
)

$SetupExe = Join-Path $SourcePath "setup.exe"

if (-Not (Test-Path $SetupExe)) {
    Write-Host "ERROR: setup.exe not found at $SetupExe" -ForegroundColor Red
    exit 1
}

Write-Host "Running Windows 11 compatibility scan from: $SourcePath" -ForegroundColor Cyan

# Run setup.exe with parameters
Start-Process -FilePath $SetupExe -ArgumentList "/quiet /compat scanonly /eula accept /showoobe none /dynamicupdate disable /priority low /skipfinalize" -Wait -NoNewWindow

Write-Host "Scan completed. Check logs under C:\$WINDOWS.~BT\Sources\Panther" -ForegroundColor Green
