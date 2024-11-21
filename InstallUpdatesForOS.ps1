# This script installs the NuGet and PSWindowsUpdate modules (if not already installed), updates Windows, and forces the installation of all available updates.
try 
{ 

if(Get-PackageProvider | Where-Object {$_.Name -eq "Nuget"}) 
{ 
"Nuget Module already exists" 
} 

else 
{ 
"Installing nuget module" 
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force 
} 

if(Get-Module -ListAvailable | where-object {$_.Name -eq "PSWindowsUpdate"}) 
{ 
"PSWindowsUpdate module already exists" 
} 

else 
{ 
"Installing PSWindowsUpdate Module" 
install-Module PSWindowsUpdate -Force 
} 

Import-Module -Name PSWindowsUpdate 

"Starting updation -->" + (Get-Date -Format "dddd MM/dd/yyyy HH:mm")  

install-WindowsUpdate -AcceptAll -ForceDownload -ForceInstall -IgnoreReboot 

"Updation completed -->"+ (Get-Date -Format "dddd MM/dd/yyyy HH:mm") 

} 

catch { 

Write-Output $_.Exception.Message 

}

