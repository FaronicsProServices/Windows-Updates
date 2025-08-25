# Optional: Bypass hardware checks if needed
reg add "HKLM\SYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d 1 /f

# Ensure the ISO contents (setup.exe and sources folder) are in C:\Win11setup
$setupPath = "C:\Win11Upgrade\setup.exe"

# Launch the upgrade, fully silent, NO REBOOT
Start-Process -FilePath $setupPath -ArgumentList "/auto upgrade /quiet /noreboot /dynamicupdate disable /eula accept /migratedrivers all /showoobe none /telemetry disable /compat ignorewarning" -Wait -NoNewWindow
