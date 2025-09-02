param (
    [switch]$Reboot
)

$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# Create registry key if not present
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Set the required registry values
Set-ItemProperty -Path $regPath -Name "ProductVersion" -Value "Windows 11" -Type String
Set-ItemProperty -Path $regPath -Name "TargetReleaseVersion" -Value 1 -Type DWord
Set-ItemProperty -Path $regPath -Name "TargetReleaseVersionInfo" -Value "24H2" -Type String

Write-Host "Registry changes applied."

if ($Reboot) {
    Write-Host "System will reboot now to apply changes."
    Restart-Computer -Force
} else {
    Write-Host "Please reboot the system manually to make the changes effective."
}
