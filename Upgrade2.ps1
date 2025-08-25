# Set PowerShell execution policy to RemoteSigned for current user
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine

$logDir = "C:\Win11Upgrade"
$logFile = "$logDir\UpgradeDeployment.log"

# Create directory if it doesn't exist
if (-Not (Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force
}

function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

try {
    Write-Log "Starting Windows 11 upgrade deployment script."

    # Registry changes to bypass TPM/CPU/SecureBoot checks
    reg add "HKLM\SYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d 1 /f
    Write-Log "Applied AllowUpgradesWithUnsupportedTPMOrCPU registry key."

    reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d 1 /f
    Write-Log "Applied BypassTPMCheck registry key."

    reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d 1 /f
    Write-Log "Applied BypassSecureBootCheck registry key."

    $setupPath = "C:\Win11Upgrade\Setup.exe"

    # Verify file exists before proceeding
    if (-Not (Test-Path -Path $setupPath)) {
        Write-Log "ERROR: Setup executable not found at $setupPath. Aborting."
        exit 1
    }
    Write-Log "Confirmed setup.exe exists at $setupPath."

    # Start upgrade process silently without reboot, logging output
    Write-Log "Starting upgrade process."
    Start-Process -FilePath $setupPath `
        -ArgumentList "/auto upgrade /quiet /noreboot /dynamicupdate disable /eula accept /migratedrivers all /showoobe none /telemetry disable /compat ignorewarning" `
        -WorkingDirectory $logDir -Wait -NoNewWindow
    Write-Log "Upgrade process launched successfully."

} catch {
    Write-Log "Exception occurred: $_"
    exit 1
}

Write-Log "Upgrade deployment script completed."
exit 0
