Start-Process -FilePath 'C:\Win11Upgrade\setup.exe' -ArgumentList '/quiet', '/noreboot', '/dynamicupdate disable', '/showoobe none', '/eula accept' -Verb RunAs -Wait
