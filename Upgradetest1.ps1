<#
.SYNOPSIS
  All-in-One Windows 10 → Windows 11 Upgrade Script
  - Mounts ISO from PDC file share with hardcoded credentials
  - Bypasses TPM/CPU checks (optional)
  - Performs silent in-place upgrade
  - Logs actions to C:\Windows\Temp\Win11Upgrade.log
#>

# --------- CONFIG ---------
$ISOPath      = "\\pdc\Deploy\Windows11.iso"   # UNC path to ISO
$DomainUser   = "CORP\Administrator"               # Hardcoded domain user
$Password     = "Partners@2024"                    # Hardcoded password (insecure!)
$BypassChecks = $true                             # Skip TPM/SecureBoot/CPU checks
$DynamicUpdate = "enable"                         # enable | disable
$RebootAfter  = $true                             # Reboot after upgrade
$LogFile      = "C:\Windows\Temp\Win11Upgrade.log"
# --------------------------

Start-Transcript -Path $LogFile -Append

Write-Output "[$(Get-Date)] Starting Windows 11 upgrade…"

# Map ISO share with credentials
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential($DomainUser, $SecurePassword)
New-PSDrive -Name "Z" -PSProvider FileSystem -Root (Split-Path $ISOPath) -Credential $Cred -Persist -ErrorAction Stop

# Copy ISO locally
$LocalISO = "C:\Temp\Win11.iso"
if (!(Test-Path "C:\Temp")) { New-Item -Path "C:\Temp" -ItemType Directory | Out-Null }
Copy-Item $ISOPath $LocalISO -Force

# Dismount PSDrive
Remove-PSDrive -Name "Z" -Force

# Mount ISO
$Mount = Mount-DiskImage -ImagePath $LocalISO -PassThru
$DriveLetter = ($Mount | Get-Volume).DriveLetter + ":"

# Optional: Bypass hardware checks
if ($BypassChecks) {
    reg add "HKLM\SYSTEM\Setup\MoSetup" /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f
}

# Run setup
$SetupExe = Join-Path $DriveLetter "setup.exe"
$Args = "/auto upgrade /quiet /noreboot /dynamicupdate $DynamicUpdate /compat ignorewarning /showoobe none /copylogs $env:SystemDrive\Windows\Temp"
Write-Output "[$(Get-Date)] Running: $SetupExe $Args"
$process = Start-Process -FilePath $SetupExe -ArgumentList $Args -Wait -PassThru

# Check result
Write-Output "[$(Get-Date)] Setup exit code: $($process.ExitCode)"

# Dismount ISO
Dismount-DiskImage -ImagePath $LocalISO

# Reboot if enabled
if ($RebootAfter) {
    Write-Output "[$(Get-Date)] Rebooting in 1 minute…"
    shutdown.exe /r /t 60 /c "Windows 11 Upgrade Completed. Restarting…"
}

Stop-Transcript
