# === Setup Variables ===
$share = "\\pdc\Deploy2"
$localPath = "C:\Win11_Upgrade"
$setupExe = "$localPath\setup.exe"
$logFile = "$localPath\upgrade_log.txt"
$username = "CORP\Administrator"
$password = "Partners@2024"
$maxAttempts = 5
$waitSeconds = 10

# === Create credential object ===
$secPassword = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $secPassword)

# === Attempt to map network drive with retry ===
$driveLetter = "Z:"
$attempt = 1
$shareReady = $false

while ($attempt -le $maxAttempts -and -not $shareReady) {
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Checking for share path attempt $attempt of $maxAttempts..."
    Try {
        New-PSDrive -Name "Z" -PSProvider FileSystem -Root $share -Credential $cred -ErrorAction Stop | Out-Null
        if (Test-Path "Z:\setup.exe") {
            $shareReady = $true
        } else {
            Remove-PSDrive -Name "Z" -Force -ErrorAction SilentlyContinue
            throw "setup.exe not found."
        }
    } Catch {
        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Share not reachable or setup.exe not found. Retrying in $waitSeconds seconds..."
        Start-Sleep -Seconds $waitSeconds
        $attempt++
    }
}

if (-not $shareReady) {
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: Network share not reachable or setup.exe not found after $maxAttempts attempts."
    Exit 1
}

# === Create local folder ===
if (!(Test-Path $localPath)) {
    New-Item -Path $localPath -ItemType Directory | Out-Null
}

# === Copy files from share ===
Write-Host "Copying Windows 11 setup files..."
Copy-Item -Path "Z:\*" -Destination $localPath -Recurse -Force

# === Unmap network drive ===
Remove-PSDrive -Name "Z"

# === Registry Bypass Keys ===
$labConfig = "HKLM:\SYSTEM\Setup\LabConfig"
if (!(Test-Path $labConfig)) {
    New-Item -Path $labConfig -Force | Out-Null
}
Set-ItemProperty -Path $labConfig -Name BypassTPMCheck -Value 1 -Type DWord
Set-ItemProperty -Path $labConfig -Name BypassSecureBootCheck -Value 1 -Type DWord
Set-ItemProperty -Path $labConfig -Name BypassRAMCheck -Value 1 -Type DWord
Set-ItemProperty -Path $labConfig -Name BypassStorageCheck -Value 1 -Type DWord
Set-ItemProperty -Path $labConfig -Name BypassCPUCheck -Value 1 -Type DWord

# === Run setup.exe ===
Write-Host "Starting Windows 11 upgrade setup..."
Start-Process -FilePath $setupExe `
    -ArgumentList "/auto upgrade /quiet /dynamicupdate disable /eula accept" `
    -Wait -NoNewWindow `
    -PassThru | Tee-Object -FilePath $logFile

Write-Host "Windows 11 upgrade launched. Check $logFile for exit code or errors."
