# ====================================================================
# Windows 11 In-Place Upgrade Script (using ISO from file server)
# ====================================================================

# Local path where ISO will be stored
$DownloadPath = "C:\Windows\Temp\Win11_24H2.iso"

# UNC path to ISO on PDC / File Server
$SourcePath = "\\pdc\Deploy\Windows11.iso"

# Upgrade arguments
$Arguments = ""

# ---- Hardcoded domain credentials ----
$UserName = "CORP\Administrator"    # Replace with your domain\user
$Password = "Partners@2024" # Replace with password

# Convert password to secure string
$SecurePass = ConvertTo-SecureString $Password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($UserName, $SecurePass)

# --------------------------------------------------------------------
# Copy ISO from file server if not already present
# --------------------------------------------------------------------
if (!(Test-Path $DownloadPath)) {
    Write-Host "ISO not found locally. Copying from $SourcePath ..."
    try {
        # Map network drive temporarily using credentials
        New-PSDrive -Name "Z" -PSProvider FileSystem -Root (Split-Path $SourcePath -Parent) -Credential $Cred -ErrorAction Stop | Out-Null
        
        # Copy ISO
        Copy-Item "Z:\$(Split-Path $SourcePath -Leaf)" $DownloadPath -Force

        # Remove temporary mapping
        Remove-PSDrive "Z"

        Write-Host "Copied ISO to $DownloadPath"
    }
    catch {
        Write-Host "Failed to copy ISO: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Host "ISO already exists at $DownloadPath, skipping copy."
}

# --------------------------------------------------------------------
# Mount ISO
# --------------------------------------------------------------------
Write-Host "Mounting ISO File"
$vol = Mount-DiskImage -ImagePath $DownloadPath -PassThru |
    Get-DiskImage | 
    Get-Volume
$setup = '{0}:\setup.exe' -f $vol.DriveLetter

# --------------------------------------------------------------------
# Run upgrade
# --------------------------------------------------------------------
Write-Host "Starting Windows 11 Upgrade with arguments: $Arguments"
Start-Process cmd.exe -Wait -ArgumentList "/c `"$setup`" $Arguments"

# --------------------------------------------------------------------
# Cleanup (optional: eject ISO after upgrade)
# --------------------------------------------------------------------
Write-Host "Ejecting ISO"
Dismount-DiskImage -ImagePath $DownloadPath

Write-Host "Finished installing - if errors occur, try running without the /quiet command"
