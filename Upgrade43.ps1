$SetupPath = "C:\Win11Upgrade\sources\setupprep.exe"
$Arguments = "/product server /auto upgrade /quiet /noreboot /dynamicupdate disable /migratedrivers none /eula accept /uninstall disable /compat ignorewarning /copylogs C:\Install\WinSetup.log"

Write-Host "Launching Windows Server upgrade..."
Start-Process -FilePath $SetupPath -ArgumentList $Arguments -Wait -NoNewWindow
