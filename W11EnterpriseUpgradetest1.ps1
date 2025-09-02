param (
    [string]$SetupPath = "\\pdc\Deploy\W11Enterprise\setup.exe",
    [string]$Username,
    [string]$Password
)

# Extract directory and file from SetupPath
$setupDirectory = Split-Path -Path $SetupPath -Parent
$setupExeName = Split-Path -Path $SetupPath -Leaf

# Convert plain text password to secure string
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Create PSCredential object
$creds = New-Object System.Management.Automation.PSCredential ($Username, $securePassword)

# Map the UNC directory to an available drive letter
$driveLetter = "Z:"
while (Get-PSDrive -Name $driveLetter.Substring(0,1) -ErrorAction SilentlyContinue) {
    $driveLetter = [char]([int][char]$driveLetter + 1) + ":"
    if ([char]([int][char]$driveLetter.Substring(0,1)) -gt 'Z') {
        Write-Error "No available drive letters to map network share."
        exit 1
    }
}

try {
    # Map network drive with credentials
    New-PSDrive -Name $driveLetter.Substring(0,1) -PSProvider FileSystem -Root $setupDirectory -Credential $creds -ErrorAction Stop | Out-Null

    $setupExeMappedPath = Join-Path -Path $driveLetter -ChildPath $setupExeName

    # Check if setup.exe exists on mapped drive
    if (-Not (Test-Path -Path $setupExeMappedPath)) {
        Write-Error "setup.exe not found at $setupExeMappedPath"
        Remove-PSDrive -Name $driveLetter.Substring(0,1) -Force
        exit 1
    }

    # Define setup.exe arguments for silent upgrade
    $arguments = "/auto upgrade /quiet /noreboot /dynamicupdate disable /compat ignorewarning /showoobe none /eula accept"

    Write-Host "Starting Windows 11 upgrade from $setupExeMappedPath ..."

    # Start the upgrade process silently and wait for it to complete
    $process = Start-Process -FilePath $setupExeMappedPath -ArgumentList $arguments -Wait -PassThru

    # Remove the mapped drive after use
    Remove-PSDrive -Name $driveLetter.Substring(0,1) -Force

    # Check exit code
    if ($process.ExitCode -eq 0) {
        Write-Host "Windows 11 upgrade initiated successfully."
        Write-Host "Please reboot the system manually to complete the upgrade."
    } else {
        Write-Error "Windows 11 upgrade failed with exit code $($process.ExitCode)."
        exit $process.ExitCode
    }
}
catch {
    Write-Error "Failed to map network drive or run setup.exe: $_"
    exit 1
}
