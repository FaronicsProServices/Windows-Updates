@echo off
echo Starting Windows Server in-place upgrade...
cd /d "C:\Win11Upgrade\sources"
start "" setupprep.exe /product server /auto upgrade /quiet
exit /b %errorlevel%
