param (
    [string]$UNCPath = "\\pdc\Deploy\W11Enterprise",
    [string]$Username,
    [string]$Password,
    [string]$LocalPath = "C:\Temp\W11Enterprise"
)

# Convert password to secure string
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)

# Map UNC temporarily
New-PSDrive -Name "Z" -PSProvider FileSystem -Root $UNCPath -Credential $creds -ErrorAction Stop | Out-Null

# Create local folder if not exists
if (-not (Test-Path -Path $LocalPath)) {
    New-Item -Path $LocalPath -ItemType Directory -Force | Out-Null
}

# Copy all contents from UNC to local folder
Copy-Item -Path "Z:\*" -Destination $LocalPath -Recurse -Force

# Remove mapped drive
Remove-PSDrive -Name "Z" -Force

# Path to setup locally
$setupExe = Join-Path -Path $LocalPath -ChildPath "setup.exe"

# Silent upgrade arguments
$arguments = "/auto upgrade /quiet /noreboot /dynamicupdate disable /compat ignorewarning /showoobe none /eula accept"

Write-Host "Starting Windows 11 upgrade from local path $setupExe ..."

# Start process silently
$process = Start-Process -FilePath $setupExe -ArgumentList $arguments -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "Windows 11 upgrade initiated successfully."
    Write-Host "Please reboot the system manually to complete the upgrade."
} else {
    Write-Error "Windows 11 upgrade failed with exit code $($process.ExitCode)."
    exit $process.ExitCode
}
