# SCRIPT NAME: Run-25H2-Upgrade-Task.ps1
# Purpose: Downloads the Windows 11 Installation Assistant and schedules it to run silently 
#          under the current user's elevated context to begin the upgrade to 25H2.
# Requires: Elevated (Administrator) PowerShell session.

# Set error action preference to ensure the script stops on critical errors
$ErrorActionPreference = "Stop"

try {
    Write-Host "--- Starting Windows 11 25H2 Upgrade Scheduler ---" -ForegroundColor Green
    
    # --- Configuration Variables ---
    $downloadUrl = "https://download.microsoft.com/download/db8267b0-3e86-4254-82c7-a127878a9378/Windows11InstallationAssistant.exe"
    $InstallerName = "Win11Upgrade.exe" # Use a consistent name
    $localPath = "$env:TEMP\$InstallerName"
    $taskName = "Win11_25H2_Upgrade_Task"
    
    # UPDATED ARGUMENTS for silent, automated upgrade:
    # /quietinstall: Runs in quiet mode.
    # /skipeula: Automatically accepts the EULA.
    # /auto upgrade: Performs an in-place upgrade (keeps files/apps).
    # /NoRestartUI: Suppresses the user-facing restart prompt.
    $InstallerArguments = "/quietinstall /skipeula /auto upgrade /NoRestartUI"
    $DelaySeconds = 30
    
    # --- 1. Download the Installation Assistant ---
    Write-Host "1. Downloading Installation Assistant from Microsoft..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $localPath -UseBasicParsing -ErrorAction Stop
        Write-Host "   Download successful. Installer saved to: $localPath" -ForegroundColor Green
    }
    catch {
        Write-Host "2. ERROR: Failed to download installer. Check URL and connectivity." -ForegroundColor Red
        Write-Host "   Error details: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    
    # --- 2. Setup Scheduled Task ---
    
    # Get current user information
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    Write-Host "Current user context for task: $currentUser" -ForegroundColor Cyan
    
    # Calculate trigger time
    $triggerTime = (Get-Date).AddSeconds($DelaySeconds)
    Write-Host "Task scheduled to run at: $($triggerTime.ToString('HH:mm:ss')) (in $DelaySeconds seconds)" -ForegroundColor Cyan
    
    # Remove existing task if it exists
    Write-Host "Checking for existing scheduled task..." -ForegroundColor Yellow
    try {
        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Write-Host "Removing existing task '$taskName'..." -ForegroundColor Yellow
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        }
    }
    catch {
        # Task doesn't exist, continue
    }
    
    # Create scheduled task action - EXECUTES THE .EXE DIRECTLY
    Write-Host "Creating task action to run: $localPath $InstallerArguments" -ForegroundColor Yellow
    $action = New-ScheduledTaskAction -Execute $localPath -Argument $InstallerArguments
    
    # Create trigger
    $trigger = New-ScheduledTaskTrigger -Once -At $triggerTime
    
    # Create principal to run with current user and highest privileges
    $principal = New-ScheduledTaskPrincipal -UserId $currentUser `
        -LogonType Interactive `
        -RunLevel Highest
    
    # Create task settings (allow start on batteries, set max execution time)
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Hours 4) ` # Set a generous time limit
        -Priority 4
    
    # Register the scheduled task
    Write-Host "Registering scheduled task..." -ForegroundColor Yellow
    $task = Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Description "Windows 11 25H2 In-Place Upgrade (Silent)" `
        -Force
    
    Write-Host "Scheduled task '$taskName' created successfully!" -ForegroundColor Green
    
    # --- 3. Countdown and Final Notes ---
    Write-Host "`nThe Windows 11 upgrade is starting in $DelaySeconds seconds!" -ForegroundColor Green
    
    # Display countdown
    Write-Host "Starting countdown..." -ForegroundColor Cyan
    for ($i = $DelaySeconds; $i -gt 0; $i--) {
        Write-Progress -Activity "Windows 11 25H2 Upgrade Starting In" -Status "$i seconds remaining" -PercentComplete (($DelaySeconds-$i)/$DelaySeconds*100)
        Start-Sleep -Seconds 1
    }
    Write-Progress -Activity "Windows 11 25H2 Upgrade Starting In" -Completed
    
    Write-Host "`nUpgrade task should now be running!" -ForegroundColor Green
    Write-Host "The upgrade process is silent. Your computer will reboot automatically when necessary." -ForegroundColor Yellow
}
catch {
    Write-Host "`nFATAL ERROR: A script error occurred before the task could start." -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Write-Host "`nScript execution completed." -ForegroundColor Cyan
}
