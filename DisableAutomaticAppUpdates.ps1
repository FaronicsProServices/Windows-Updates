# This script configures the AutoDownload policy for the Windows Store by setting the registry value.
$Name = “AutoDownload” 
$Value = 2 
$Path = “HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore” 
If ((Test-Path $Path) -eq $false){ 
New-Item -Path $Path -ItemType Directory 
} 
If (-!(Get-ItemProperty -Path $Path -Name $name -ErrorAction SilentlyContinue)){ 
New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value 
} 
else{ 
Set-ItemProperty -Path $Path -Name $Name -Value $Value 
}
