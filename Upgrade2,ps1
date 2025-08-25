# Windows 11 Silent Upgrade Script
# This script triggers the Windows 11 upgrade process silently

param(
    [string]$SetupPath = "C:\Win11Upgrade\setup.exe",
    [string]$LogPath = "C:\Win11Upgrade\upgrade.log"
)

# Function to write logs
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogPath -Append
    Write-Host "$timestamp - $Message"
}

try {
    Write-Log "Starting Windows 11 upgrade process"
    
    # Check if setup.exe exists
    if (-not (Test-Path $SetupPath)) {
        Write-Log "ERROR: Setup file not found at $SetupPath"
        exit 1
    }
    
    Write-Log "Setup file found at $SetupPath"
    
    # Get current Windows version for logging
    $currentVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
    Write-Log "Current Windows version: $currentVersion"
    
    # Silent upgrade parameters
    $arguments = @(
        "/auto", "upgrade",           # Automatic upgrade mode
        "/quiet",                    # Silent installation
        "/compat", "IgnoreWarning",  # Ignore compatibility warnings
        "/dynamicupdate", "enable",  # Enable dynamic updates
        "/skipeula",                 # Skip EULA
        "/showoobe", "none"          # Skip OOBE
    )
    
    Write-Log "Starting upgrade with arguments: $($arguments -join ' ')"
    
    # Start the upgrade process
    $process = Start-Process -FilePath $SetupPath -ArgumentList $arguments -PassThru -NoNewWindow
    
    Write-Log "Upgrade process started with PID: $($process.Id)"
    Write-Log "Upgrade initiated successfully. System will restart when complete."
    
    # Optional: Wait for process to complete (may take a long time)
    # $process.WaitForExit()
    # Write-Log "Upgrade process completed with exit code: $($process.ExitCode)"
    
} catch {
    Write-Log "ERROR: Failed to start upgrade process - $($_.Exception.Message)"
    exit 1
}

Write-Log "Script execution completed"
