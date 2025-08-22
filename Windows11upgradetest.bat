@echo off
:: Path to the mounted or extracted Windows 11 setup files
set setup_path=C:\Win11Upgrade\setup.exe

:: Run the setup silently
%setup_path% /auto upgrade /quiet /skipeula /dynamicupdate disable
