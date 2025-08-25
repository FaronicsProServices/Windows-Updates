$workingdir = "C:\temp\"
$url = "https://go.microsoft.com/fwlink/?linkid=2171764"
$file = "$workingdir\Win11Upgrade.exe"

# Check if the working directory exists, if not, create it
if (!(Test-Path $workingdir)) {
    New-Item -ItemType Directory -Force -Path $workingdir
}

# Download the file
try {
    Invoke-WebRequest -Uri $url -OutFile $file
    Write-Host "Download completed successfully."
} catch {
    Write-Host "Error downloading the file: $_"
    exit 1
}

# Start the upgrade process
try {
    Start-Process -FilePath $file -ArgumentList "/Install /MinimizeToTaskBar /QuietInstall /SkipEULA /copylogs $workingdir" -Wait
    Write-Host "Upgrade process started."
} catch {
    Write-Host "Error starting the upgrade process: $_"
    exit 1
}
