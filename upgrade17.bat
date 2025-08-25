@echo off
REM ========================================
REM Windows 10 -> Windows 11 Upgrade Script
REM Supports UNC path and local path
REM ========================================

:: Change this to your source path (UNC or local)
set "SourcePath=C:\Win11Upgrade" 
:: Example local path: set "SourcePath=C:\Win11Setup"

set "SetupExe=%SourcePath%\setup.exe"

:: Check if setup.exe exists
if not exist "%SetupExe%" (
    echo ERROR: setup.exe not found at "%SetupExe%"
    pause
    exit /b 1
)

echo Running Windows 11 Upgrade...
echo Source: %SourcePath%
echo.

:: Run upgrade with given switches
"%SetupExe%" /auto upgrade /quiet /compat scanonly /eula accept /showoobe none /dynamicupdate disable /priority low /skipfinalize

echo.
echo Upgrade command executed. Check logs under C:\$WINDOWS.~BT\Sources\Panther
pause
