@echo off
REM ===============================================
REM Windows 11 In-Place Upgrade Script (using setupprep.exe)
REM Compatible with Faronics Deploy
REM ===============================================

REM Change directory to where setupprep.exe is located
cd /d "C:\Win11Upgrade\sources"

REM Run Windows 11 setup with required parameters
setupprep.exe /product server ^
/auto upgrade ^
/migratedrivers none ^
/dynamicupdate disable ^
/eula accept ^
/quiet ^
/noreboot ^
/uninstall disable ^
/compat ignorewarning ^
/copylogs C:\Install\WinSetup.log

REM Capture exit code for reporting
set EXITCODE=%ERRORLEVEL%

echo SetupPrep exited with code %EXITCODE% >> C:\Install\UpgradeExitCode.log

exit /b %EXITCODE%
