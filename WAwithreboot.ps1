<#
.SYNOPSIS
    Automates Windows 10 to Windows 11 in-place upgrade with detailed logging.

.DESCRIPTION
    Downloads the Windows 11 Installation Assistant and performs the upgrade silently.
    Monitors the process, waits for completion, and collects logs.

.NOTES
    Run as Administrator.
#>

# Variables
$DownloadUrl = "https://go.microsoft.com/fwlink/?linkid=2171764"   # Windows 11 Installation Assistant
$InstallerPath = "$env:TEMP\Win11Upgrade.exe"
$LogDir = "C:\Win11UpgradeLogs"
$LogFile = "$LogDir\Upgrade.log"
$SetupLogsSource = "C:\$WINDOWS.~BT\Sources\Panther"
$SetupLogsDest = "$LogDir\SetupLogs"

# Create log directory
if (!(Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}
if (!(Test-Path $SetupLogsDest)) {
    New-Item -Path $SetupLogsDest -ItemType Directory -Force | Out-Null
}

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $TimeStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $LogMessage = "$TimeStamp [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage
    Write-Host $LogMessage
}

Write-Log "=== Windows 10 to Windows 11 Upgrade Script Started ==="

try {
    # Step 1: Download Installer
    Write-Log "Downloading Windows 11 Installation Assistant..."
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $InstallerPath -ErrorAction Stop
    Write-Log "Download completed: $InstallerPath"

    # Step 2: Run Installer
    Write-Log "Launching Installation Assistant silently..."
    $process = Start-Process -FilePath $InstallerPath -ArgumentList "/quietinstall", "/norestart", "/eula accept" -PassThru -Verb RunAs

    # Step 3: Monitor Installer
    Write-Log "Monitoring process: $($process.Id)"
    Wait-Process -Id $process.Id
    $ExitCode = $process.ExitCode
    Write-Log "Installer finished with Exit Code: $ExitCode"

    # Step 4: Collect setup logs if they exist
    if (Test-Path $SetupLogsSource) {
        Write-Log "Collecting setup logs from $SetupLogsSource"
        Copy-Item -Path "$SetupLogsSource\*" -Destination $SetupLogsDest -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Setup logs copied to $SetupLogsDest"
    } else {
        Write-Log "No setup logs found (upgrade may not have started)." "WARNING"
    }

    # Step 5: Interpret exit codes (basic)
    switch ($ExitCode) {
        0 { Write-Log "Windows 11 upgrade initiated successfully. Expect reboots soon." }
        3010 { Write-Log "Upgrade staged. A reboot is required to continue installation." }
        default { Write-Log "Unexpected exit code: $ExitCode" "ERROR" }
    }
}
catch {
    Write-Log "Script error: $_" "ERROR"
}

Write-Log "=== Script Completed ==="
