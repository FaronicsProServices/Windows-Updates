# Run this script as Administrator in PowerShell

Write-Host "`nChecking Windows 11 hardware requirements..." -ForegroundColor Cyan

$compatible = $true  # Overall compatibility tracker

# Check CPU Architecture
$cpuArch = (Get-CimInstance Win32_Processor).Architecture
if ($cpuArch -eq 9) {
    Write-Host "CPU Architecture: 64-bit" -ForegroundColor Green
} else {
    Write-Host "CPU Architecture: Not 64-bit" -ForegroundColor Red
    $compatible = $false
}

# Check RAM
$ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
if ($ram -ge 4) {
    Write-Host "RAM: $([math]::Round($ram, 2)) GB" -ForegroundColor Green
} else {
    Write-Host "RAM: $([math]::Round($ram, 2)) GB (Minimum 4 GB required)" -ForegroundColor Red
    $compatible = $false
}

# Check Storage
$systemDrive = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
if ($systemDrive.Size -ge 64GB) {
    Write-Host "Storage: $([math]::Round($systemDrive.Size / 1GB, 2)) GB" -ForegroundColor Green
} else {
    Write-Host "Storage: $([math]::Round($systemDrive.Size / 1GB, 2)) GB (Minimum 64 GB required)" -ForegroundColor Red
    $compatible = $false
}

# Check TPM version
$tpm = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm
if ($tpm -and $tpm.SpecVersion -match "2.0") {
    Write-Host "TPM: 2.0 detected" -ForegroundColor Green
} elseif ($tpm) {
    Write-Host "TPM: Found but not version 2.0 (Found: $($tpm.SpecVersion))" -ForegroundColor Red
    $compatible = $false
} else {
    Write-Host "TPM: Not detected" -ForegroundColor Red
    $compatible = $false
}

# Check Secure Boot
try {
    $sb = Confirm-SecureBootUEFI
    if ($sb -eq $true) {
        Write-Host "Secure Boot: Enabled" -ForegroundColor Green
    } elseif ($sb -eq $false) {
        Write-Host "Secure Boot: Disabled or Unsupported" -ForegroundColor Red
        $compatible = $false
    }
} catch {
    Write-Host "Secure Boot: Not supported or BIOS mode detected" -ForegroundColor Red
    $compatible = $false
}

# Check Disk Partition Style (GPT)
$disk = Get-Disk | Where-Object IsSystem -eq $true
if ($disk.PartitionStyle -eq 'GPT') {
    Write-Host "Partition Style: GPT" -ForegroundColor Green
} else {
    Write-Host "Partition Style: MBR (GPT required)" -ForegroundColor Red
    $compatible = $false
}

# Check UEFI Firmware (with fallback and smart assumption)
$firmware = (Get-CimInstance -ClassName Win32_ComputerSystem).FirmwareType
if ($firmware -eq 2) {
    Write-Host "Firmware: UEFI detected (via WMI)" -ForegroundColor Green
} elseif ($firmware -eq 1) {
    Write-Host "Firmware: BIOS/Legacy detected (via WMI)" -ForegroundColor Red
    $compatible = $false
} else {
    # Try BCD path as fallback
    $bcdPath = (bcdedit | Select-String "path").ToString()
    if ($bcdPath -match "winload.efi") {
        Write-Host "Firmware: UEFI (Detected from bootloader path)" -ForegroundColor Green
    } elseif ($bcdPath -match "winload.exe") {
        Write-Host "Firmware: BIOS/Legacy (Detected from bootloader path)" -ForegroundColor Red
        $compatible = $false
    } else {
        # Final fallback: assume UEFI if all other criteria are met
        if ($tpm -and $sb -eq $true -and $disk.PartitionStyle -eq 'GPT' -and [System.Environment]::OSVersion.Version.Major -ge 10) {
            Write-Host "Firmware: UEFI (Assumed based on other validated parameters)" -ForegroundColor Green
        } else {
            Write-Host "Firmware: Unknown (WMI and BCD both inconclusive)" -ForegroundColor Yellow
            $compatible = $false
        }
    }
}

# Final Summary
Write-Host "`nSummary:" -ForegroundColor Cyan
if ($compatible) {
    Write-Host "This device meets the minimum hardware requirements for Windows 11." -ForegroundColor Green
} else {
    Write-Host "This device does NOT meet all the minimum hardware requirements for Windows 11." -ForegroundColor Red
}

Write-Host "`nFor a full compatibility report including CPU model support, please use the official Windows 11 Installation Assistant:" -ForegroundColor Yellow
Write-Host "https://www.microsoft.com/software-download/windows11" -ForegroundColor Blue

Write-Host "`nHardware check completed." -ForegroundColor Cyan
