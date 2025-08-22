$setupPath = "C:\Win11Upgrade\setup.exe"
Start-Process -FilePath $setupPath -ArgumentList "/auto upgrade", "/quiet", "/skipeula", "/dynamicupdate disable" -Wait
