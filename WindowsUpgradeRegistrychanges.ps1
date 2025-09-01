# Apply Windows Update Target Release Version for Windows 11 Upgrade

$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# Create the key if it does not exist
If (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set registry values
Set-ItemProperty -Path $RegPath -Name "TargetReleaseVersion" -Value 1 -Type DWord
Set-ItemProperty -Path $RegPath -Name "TargetReleaseVersionInfo" -Value "24H2" -Type String

Write-Host "Registry updated. Device will target Windows 11 24H2 upgrade." -ForegroundColor Green
