<#
.SYNOPSIS
    Windows 10 → Windows 11 Enterprise 24H2 Upgrade Script (All-in-One)
    Works with PDQ, Intune, Deep Freeze Cloud, Faronics Deploy

.NOTES
    - Uses embedded credentials for share access
    - Mounts ISO, runs setup.exe silently, reboots automatically
    - Logs upgrade output to C:\Win11Upgrade\upgrade.log
#>

param(
    [string]$ISOPath = "\\pdc\Deploy\Windows11.iso",

    # Embed your domain credentials here
    [string]$UserName = "CORP\\Administrator",
    [string]$PlainPassword = "Partners@2024",

    [switch]$BypassChecks,
    [switch]$RebootAfter
)

# Create local working directory
$WorkDir = "C:\Win11Upgrade"
New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null

# Convert plain password into secure string
$SecurePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($UserName, $SecurePassword)

# Map drive to access ISO
$DriveLetter = "Z:"
Try {
    Write-Host "Mapping $ISOPath to $DriveLetter..."
    New-PSDrive -Name "Z" -PSProvider FileSystem -Root (Split-Path $ISOPath) -Credential $Cred -ErrorAction Stop | Out-Null
}
Catch {
    Write-Error "Failed to map network share. $_"
    Exit 1
}

# Copy ISO locally
$LocalISO = "$WorkDir\Windows11.iso"
Copy-Item $ISOPath $LocalISO -Force
Write-Host "ISO copied to $LocalISO"

# Unmap drive
Remove-PSDrive -Name "Z" -Force

# Mount ISO
$MountResult = Mount-DiskImage -ImagePath $LocalISO -PassThru
$ISODriveLetter = ($MountResult | Get-Volume).DriveLetter + ":"
Write-Host "Mounted ISO at $ISODriveLetter"

# Optional bypass for TPM/CPU checks
if ($BypassChecks) {
    $RegPath = "HKLM:\SYSTEM\Setup\MoSetup"
    if (-not (Test-Path $RegPath)) { New-Item $RegPath -Force | Out-Null }
    Set-ItemProperty -Path $RegPath -Name "AllowUpgradesWithUnsupportedTPMOrCPU" -Value 1 -Type DWord
    Write-Host "Enabled bypass for TPM/CPU checks."
}

# Run setup.exe for in-place upgrade
$SetupExe = "$ISODriveLetter\setup.exe"
$Args = "/auto upgrade /quiet /noreboot /dynamicupdate enable /copylogs $WorkDir"

Write-Host "Starting upgrade..."
Start-Process -FilePath $SetupExe -ArgumentList $Args -Wait -PassThru -RedirectStandardOutput "$WorkDir\upgrade.log" -RedirectStandardError "$WorkDir\upgrade.err"

# Dismount ISO
Dismount-DiskImage -ImagePath $LocalISO

# Reboot if specified
if ($RebootAfter) {
    Write-Host "Rebooting system..."
    Restart-Computer -Force
} else {
    Write-Host "Upgrade completed. Reboot required."
}
