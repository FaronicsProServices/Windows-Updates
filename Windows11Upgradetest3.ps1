$setupPath = "C:\Win11Upgrade\setup.exe"
$arguments = "/auto upgrade /quiet /skipeula /dynamicupdate disable"

Start-Process -FilePath $setupPath -ArgumentList $arguments -Wait
