# --- Variables ---
# Direct download link provided by the user (simpler than fwlink)
$DownloadURL = "https://download.microsoft.com/download/db8267b0-3e86-4254-82c7-a127878a9378/Windows11InstallationAssistant.exe"
$InstallerName = "Windows11InstallationAssistant.exe"
$DownloadPath = "$env:TEMP\$InstallerName"
# Arguments to perform an automated, silent, in-place upgrade.
$InstallerArguments = "/auto upgrade /quiet /noreboot" 

Write-Host "--- Windows 11 23H2 to 25H2 Upgrade Script ---"

# --- 1. Download the Installation Assistant ---
Write-Host "1. Downloading Windows 11 Installation Assistant..."
try {
    # Using Invoke-WebRequest for the download
    Invoke-WebRequest -Uri $DownloadURL -OutFile $DownloadPath
    Write-Host "   Download successful. File saved to: $DownloadPath"
}
catch {
    Write-Error "Download failed: $($_.Exception.Message)"
    exit 1
}

# --- 2. Launch the Silent Upgrade ---
if (Test-Path $DownloadPath) {
    Write-Host "2. Starting silent upgrade to Windows 11 25H2..."
    Write-Host "   This will take time and requires Administrator privileges."
    
    # Start the process and wait for the installer to launch the main upgrade engine
    Start-Process -FilePath $DownloadPath -ArgumentList $InstallerArguments -Verb RunAs -Wait
    
    Write-Host "3. Installation Assistant launched. The feature update is running in the background."
    Write-Host "   Monitor the VM for required reboots to complete the 25H2 upgrade."
}
else {
    Write-Error "Installer file not found. Aborting."
    exit 1
}
