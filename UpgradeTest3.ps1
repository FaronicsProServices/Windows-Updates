Invoke-Command -ComputerName DESKTOP-0HC5TGL -ScriptBlock {
    Start-Process -FilePath "C:\Win11\setup.exe" -ArgumentList "/auto upgrade /quiet /noreboot /dynamicupdate disable /eula accept /migratedrivers all /showoobe none /telemetry disable /compat ignorewarning" -Wait -NoNewWindow
}
