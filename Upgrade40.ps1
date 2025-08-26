# Optional: Elevate privileges if needed and bypass execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Set up temporary working path
$TempDir = "C:\temp"
$InstallerPath = "$TempDir\Windows11InstallationAssistant.exe"
if (!(Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
}

# Download Windows 11 Installation Assistant from official source
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2171764" -OutFile $InstallerPath

# Arguments for silent, non-interactive install and upgrade
$Args = "/quietinstall /skipeula /auto upgrade /NoRestartUI /noreboot /copylogs $TempDir"

# Start the upgrade process silently, wait until it completes, and log output
$Process = Start-Process -FilePath $InstallerPath -ArgumentList $Args -NoNewWindow -PassThru -Wait

# Check exit code and display result
if ($Process.ExitCode -eq 0) {
    Write-Output "Windows 11 upgrade process completed successfully."
} else {
    Write-Output "Upgrade failed with exit code $($Process.ExitCode). Check logs in $TempDir."
}

# Optional: Clean up installer
Remove-Item -Path $InstallerPath -Force
