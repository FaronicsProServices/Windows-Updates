<#
.SYNOPSIS
    Automates Windows 10 to Windows 11 in-place upgrade.

.DESCRIPTION
    Downloads the Windows 11 Installation Assistant and performs the upgrade silently.

.NOTES
    Run as Administrator.
    Make sure the system meets Windows 11 requirements.
#>

# Define download URL and destination
$DownloadUrl = "https://go.microsoft.com/fwlink/?linkid=2171764"   # Windows 11 Installation Assistant
$InstallerPath = "$env:TEMP\Win11Upgrade.exe"

Write-Host "Downloading Windows 11 Installation Assistant..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $DownloadUrl -OutFile $InstallerPath

if (Test-Path $InstallerPath) {
    Write-Host "Download completed: $InstallerPath" -ForegroundColor Green

    Write-Host "Starting Windows 11 Upgrade..." -ForegroundColor Cyan
    # Run the installer silently
    Start-Process -FilePath $InstallerPath -ArgumentList "/quietinstall", "/norestart", "/eula accept" -Wait -Verb RunAs

    Write-Host "Windows 11 upgrade process has been started." -ForegroundColor Yellow
    Write-Host "The system will need to restart several times during the process."
} else {
    Write-Host "Download failed. Please check your internet connection or URL." -ForegroundColor Red
}
