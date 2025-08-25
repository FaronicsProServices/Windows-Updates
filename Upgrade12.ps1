Set-ExecutionPolicy Unrestricted -Scope Process -Force

Start-Process -FilePath 'C:\Win11Upgrade\setup.exe' -ArgumentList '/quiet', '/norestart' -Verb RunAs -Wait
