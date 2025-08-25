@echo off
REM ===============================================
REM Windows 11 In-Place Upgrade Script (Minimal)
REM ===============================================

cd /d "C:\Win11Upgrade\sources"

setupprep.exe /product server /auto upgrade /quiet
