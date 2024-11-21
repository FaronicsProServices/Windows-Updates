# This script gets the most recently installed hotfix on the system.
# The numerical value can be changed depending on the number of recent hotfixes that are meant to be displayed. In case if the value is replaced with 5 then it will display 5th recent hotfix.
(Get-HotFix | Sort-Object -Property InstalledOn)[-1]
