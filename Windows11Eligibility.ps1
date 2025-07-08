# Run this script as Administrator in PowerShell

Write-Host "`nChecking Windows 11 hardware requirements..." -ForegroundColor Cyan

# Check CPU Architecture
$cpuArch = (Get-CimInstance Win32_Processor).Architecture
if ($cpuArch -eq 9) {
    Write-Host "CPU Architecture: 64-bit" -ForegroundColor Green
} else {
    Write-Host "CPU Architecture: Not 64-bit" -ForegroundColor Red
}

# Check RAM
$ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
if ($ram -ge 4) {
    Write-Host "RAM: $([math]::Round($ram, 2)) GB" -ForegroundColor Green
} else {
    Write-Host "RAM: $([math]::Round($ram, 2)) GB (Minimum 4 GB required)" -ForegroundColor Red
}

# Check Storage
$systemDrive = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
if ($systemDrive.Size -ge 64GB) {
    Write-Host "Storage: $([math]::Round($systemDrive.Size / 1GB, 2)) GB" -ForegroundColor Green
} else {
    Write-Host "Storage: $([math]::Round($systemDrive.Size / 1GB, 2)) GB (Minimum 64 GB required)" -ForegroundColor Red
}

# Check TPM version
$tpm = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm
if ($tpm -and $tpm.SpecVersion -match "2.0") {
    Write-Host "TPM: 2.0 detected" -ForegroundColor Green
} elseif ($tpm) {
    Write-Host "TPM: Found but not version 2.0 (Found: $($tpm.SpecVersion))" -ForegroundColor Red
} else {
    Write-Host "TPM: Not detected" -ForegroundColor Red
}

# Check Secure Boot
try {
    $sb = Confirm-SecureBootUEFI
    if ($sb -eq $true) {
        Write-Host "Secure Boot: Enabled" -ForegroundColor Green
    } elseif ($sb -eq $false) {
        Write-Host "Secure Boot: Disabled or Unsupported" -ForegroundColor Red
    }
} catch {
    Write-Host "Secure Boot: Not supported or BIOS mode detected" -ForegroundColor Red
}

# Check UEFI Firmware (Accurate Method)
$firmware = (Get-CimInstance -ClassName Win32_ComputerSystem).FirmwareType
switch ($firmware) {
    1 { Write-Host "Firmware: BIOS (Legacy mode detected, UEFI required)" -ForegroundColor Red }
    2 { Write-Host "Firmware: UEFI detected" -ForegroundColor Green }
    default { Write-Host "Firmware: Unknown ($firmware)" -ForegroundColor Yellow }
}

# Check Disk Partition Style (GPT)
$disk = Get-Disk | Where-Object IsSystem -eq $true
if ($disk.PartitionStyle -eq 'GPT') {
    Write-Host "Partition Style: GPT" -ForegroundColor Green
} else {
    Write-Host "Partition Style: MBR (GPT required)" -ForegroundColor Red
}

Write-Host "`nHardware check completed." -ForegroundColor Cyan
