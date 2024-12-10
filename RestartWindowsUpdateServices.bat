@echo off
net stop wuauserv
net stop cryptSvc
net stop bits
net stop msiserver
del %systemroot%\SoftwareDistribution /q /s
net start wuauserv
net start cryptSvc
net start bits
net start msiserver
echo Windows Update services restarted.
