# Enable upgrade on incompatible hardware if needed (TPM bypass)
reg add "HKLM\SYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d 1 /f

# Optional reboot (ensure registry is loaded)
shutdown /r /t 0

# Wait for reboot and relaunch script if needed, or use deployment system's scheduling.

# Path to Windows 11 Setup files (edit as needed)
$isoPath = "C:\Win11\setup.exe"

# Run Setup with recommended options
Start-Process -FilePath $isoPath -ArgumentList "/auto upgrade /quiet /noreboot /dynamicupdate disable /eula accept /migratedrivers all /showoobe none /compat ignorewarning" -Wait

# Optional: log the upgrade for tracking
Write-Output "Windows 11 upgrade initiated on $env:COMPUTERNAME at $(Get-Date)" | Out-File "C:\Temp\Win11UpgradeLog.txt" -Append
