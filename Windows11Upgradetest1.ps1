# Windows 11 In-Place Upgrade Script
# Runs setup.exe locally to upgrade Windows 10 → Windows 11 without losing profiles

param(
    [string]$SourcePath = "C:\Windows11",   # Local folder containing setup.exe
    [switch]$ForceReboot = $false             # Optional: reboot automatically after upgrade
)

# Function for logging
function Write-UpgradeLog {
    param([string]$Message)
    $LogFile = "C:\Windows11Upgrade.log"
    $TimeStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "$TimeStamp - $Message"
}

# Start logging
Write-UpgradeLog "Windows 11 upgrade script started."
Write-UpgradeLog "Source path: $SourcePath"

# Verify setup.exe exists
$SetupExe = Join-Path $SourcePath "setup.exe"
if (!(Test-Path $SetupExe)) {
    Write-UpgradeLog "ERROR: setup.exe not found in $SourcePath"
    Write-Host "setup.exe not found in $SourcePath"
    exit 1
}

Write-UpgradeLog "setup.exe found. Starting upgrade..."

# Setup arguments
$SetupArgs = "/auto upgrade /quiet /noreboot /dynamicupdate disable /migratedrivers all"

if ($ForceReboot) {
    $SetupArgs = "/auto upgrade /quiet /noreboot /dynamicupdate disable /migratedrivers all /reboot"
    Write-UpgradeLog "ForceReboot enabled."
}

# Start setup.exe (in-place upgrade)
$process = Start-Process -FilePath $SetupExe -ArgumentList $SetupArgs -Wait -PassThru

Write-UpgradeLog "Setup.exe finished with exit code: $($process.ExitCode)"
Write-Host "Upgrade completed with exit code: $($process.ExitCode). Check C:\Windows11Upgrade.log for details."
