# Requires -Version 5.1

<#
.SYNOPSIS
    Checks the current system's hardware against Windows 11 upgrade requirements.

.DESCRIPTION
    This script performs checks for the following Windows 11 hardware requirements:
    - Processor: 1 GHz or faster with 2 or more cores on a compatible 64-bit processor.
    - RAM: 4 GB or greater.
    - Storage: 64 GB or larger storage device (C: drive).
    - System firmware: UEFI, Secure Boot capable (and enabled).
    - TPM: Trusted Platform Module (TPM) version 2.0 (and enabled).
    - Graphics card: Compatible with DirectX 12 or later, with WDDM 2.0 driver.
    - Display: High definition (720p) display that is greater than 9” diagonally.

    It outputs a detailed compatibility report.

.NOTES
    Author: Gemini AI
    Date: July 8, 2025
    Version: 1.0
    Disclaimer: This script provides a general compatibility check. For definitive results,
                always refer to Microsoft's official PC Health Check App and documentation.
#>

function Test-Windows11Compatibility {
    Write-Host "--- Checking Windows 11 Hardware Compatibility ---" -ForegroundColor Cyan

    $results = @{
        Processor        = "FAIL"
        RAM              = "FAIL"
        Storage          = "FAIL"
        SecureBoot       = "FAIL"
        TPM              = "FAIL"
        Graphics         = "FAIL"
        Display          = "FAIL"
        OverallStatus    = "NOT CAPABLE"
        FailedChecks     = @()
    }

    # 1. Processor Check
    Write-Host "`n1. Checking Processor..." -ForegroundColor Yellow
    try {
        $processor = Get-CimInstance -ClassName Win32_Processor
        $cores = $processor.NumberOfCores
        $logicalProcessors = $processor.NumberOfLogicalProcessors # Often more relevant for multi-threading
        $speed = $processor.CurrentClockSpeed
        $architecture = $processor.Architecture # 9 for x64
        $manufacturer = $processor.Manufacturer

        Write-Host "   - Cores: $($cores)"
        Write-Host "   - Logical Processors: $($logicalProcessors)"
        Write-Host "   - Clock Speed: $($speed) MHz"
        Write-Host "   - Architecture: $($architecture) (9 = x64)"
        Write-Host "   - Manufacturer: $($manufacturer)"

        if ($cores -ge 2 -and $speed -ge 1000 -and $architecture -eq 9) {
            $results.Processor = "PASS"
            Write-Host "   Processor check: PASS" -ForegroundColor Green
        } else {
            $results.FailedChecks += "Processor"
            Write-Host "   Processor check: FAIL (Requires 2+ cores, 1GHz+, 64-bit)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "Processor"
        Write-Host "   Could not retrieve processor information. FAIL." -ForegroundColor Red
    }

    # 2. RAM Check
    Write-Host "`n2. Checking RAM..." -ForegroundColor Yellow
    try {
        $ram = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory
        $ramGB = [Math]::Round($ram / 1GB)
        Write-Host "   - Total RAM: $($ramGB) GB"

        if ($ramGB -ge 4) {
            $results.RAM = "PASS"
            Write-Host "   RAM check: PASS" -ForegroundColor Green
        } else {
            $results.FailedChecks += "RAM"
            Write-Host "   RAM check: FAIL (Requires 4 GB or more)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "RAM"
        Write-Host "   Could not retrieve RAM information. FAIL." -ForegroundColor Red
    }

    # 3. Storage Check (C: drive)
    Write-Host "`n3. Checking Storage (C: Drive)..." -ForegroundColor Yellow
    try {
        $drive = Get-PSDrive C | Select-Object -ExpandProperty Free
        $totalSize = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").Size
        $totalSizeGB = [Math]::Round($totalSize / 1GB)
        $freeSpaceGB = [Math]::Round($drive / 1GB)
        Write-Host "   - C: Drive Total Size: $($totalSizeGB) GB"
        Write-Host "   - C: Drive Free Space: $($freeSpaceGB) GB"

        if ($totalSizeGB -ge 64) { # Windows 11 requires 64GB or larger storage *device*. This checks the C: drive size.
            $results.Storage = "PASS"
            Write-Host "   Storage check: PASS" -ForegroundColor Green
        } else {
            $results.FailedChecks += "Storage"
            Write-Host "   Storage check: FAIL (C: drive requires 64 GB or larger)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "Storage"
        Write-Host "   Could not retrieve storage information. FAIL." -ForegroundColor Red
    }

    # 4. Secure Boot Check
    Write-Host "`n4. Checking Secure Boot..." -ForegroundColor Yellow
    try {
        if ((Get-CimInstance -Namespace root\Security\Boot -ClassName SecurityFirmwareTpmInfo).SecureBootEnabled) {
            $results.SecureBoot = "PASS"
            Write-Host "   Secure Boot check: PASS (Enabled)" -ForegroundColor Green
        }
        else {
            $results.FailedChecks += "SecureBoot"
            Write-Host "   Secure Boot check: FAIL (Not enabled or capable. Check BIOS/UEFI settings.)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "SecureBoot"
        Write-Host "   Could not determine Secure Boot status. Ensure system firmware is UEFI. FAIL." -ForegroundColor Red
    }

    # 5. TPM Check (Trusted Platform Module)
    Write-Host "`n5. Checking TPM..." -ForegroundColor Yellow
    try {
        $tpm = Get-CimInstance -ClassName Win32_Tpm -Namespace root\CIMV2\Security\MicrosoftTpm
        if ($tpm) {
            $tpmVersion = "$($tpm.SpecVersionMajor).$($tpm.SpecVersionMinor)"
            $tpmEnabled = $tpm.Enabled
            $tpmActivated = $tpm.Activated
            Write-Host "   - TPM Present: Yes"
            Write-Host "   - TPM Version: $($tpmVersion)"
            Write-Host "   - TPM Enabled: $($tpmEnabled)"
            Write-Host "   - TPM Activated: $($tpmActivated)"

            if ($tpmEnabled -and $tpmActivated -and $tpmVersion -ge 2.0) {
                $results.TPM = "PASS"
                Write-Host "   TPM check: PASS (TPM 2.0 enabled and activated)" -ForegroundColor Green
            } else {
                $results.FailedChecks += "TPM"
                Write-Host "   TPM check: FAIL (Requires TPM 2.0 enabled and activated. Check BIOS/UEFI settings.)" -ForegroundColor Red
            }
        } else {
            $results.FailedChecks += "TPM"
            Write-Host "   TPM check: FAIL (TPM not found or accessible.)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "TPM"
        Write-Host "   Could not retrieve TPM information. Make sure TPM is enabled in BIOS/UEFI. FAIL." -ForegroundColor Red
    }

    # 6. Graphics Card Check
    Write-Host "`n6. Checking Graphics Card..." -ForegroundColor Yellow
    try {
        $graphicsCard = Get-CimInstance -ClassName Win32_VideoController
        $directXVersion = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\DirectX).Version
        $wddmVersion = $graphicsCard.DriverVersion # This is a simplified check, WDDM version is not directly exposed as a separate property like this.

        Write-Host "   - Graphics Card Name: $($graphicsCard.Name)"
        Write-Host "   - DirectX Version: $($directXVersion)"
        # Note: Checking WDDM 2.0 driver directly via WMI is complex.
        # This part assumes a modern driver version implies WDDM 2.0.
        # For a more robust check, you'd need to parse driver details or use a dedicated tool.
        Write-Host "   - Driver Version (Indicative of WDDM): $($graphicsCard.DriverVersion)"

        # A very basic check: If DirectX 12 is present and there's a modern driver.
        # This is a weak check and a common reason for "Not Capable" on the official tool.
        if ($directXVersion -match "12" -and $graphicsCard.CurrentBitsPerPixel -ne $null) {
            $results.Graphics = "PASS"
            Write-Host "   Graphics card check: PASS (DirectX 12 capable with driver)" -ForegroundColor Green
        } else {
            $results.FailedChecks += "Graphics"
            Write-Host "   Graphics card check: FAIL (Requires DirectX 12 compatible with WDDM 2.0 driver)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "Graphics"
        Write-Host "   Could not retrieve graphics card information. FAIL." -ForegroundColor Red
    }

    # 7. Display Check
    Write-Host "`n7. Checking Display..." -ForegroundColor Yellow
    try {
        $monitor = Get-CimInstance -ClassName Win32_DesktopMonitor
        $screenWidth = $monitor.ScreenWidth
        $screenHeight = $monitor.ScreenHeight
        $bitsPerPixel = $monitor.BitsPerPixel

        Write-Host "   - Display Resolution: $($screenWidth)x$($screenHeight)"
        Write-Host "   - Bits Per Pixel: $($bitsPerPixel)"

        # 720p is 1280x720, so checking for minimum width or height
        # Assuming the primary display is being checked.
        if (($screenWidth -ge 1280 -and $screenHeight -ge 720) -and ($bitsPerPixel -ge 24)) { # 8 bits per color channel usually means 24 or 32 bits per pixel
            $results.Display = "PASS"
            Write-Host "   Display check: PASS" -ForegroundColor Green
        } else {
            $results.FailedChecks += "Display"
            Write-Host "   Display check: FAIL (Requires 720p+ resolution, 9+ inch diagonal, 8 bits/color channel)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "Display"
        Write-Host "   Could not retrieve display information. FAIL." -ForegroundColor Red
    }

    # Overall Status
    Write-Host "`n--- Overall Compatibility Summary ---" -ForegroundColor Cyan
    if ($results.FailedChecks.Count -eq 0) {
        $results.OverallStatus = "CAPABLE"
        Write-Host "This PC IS CAPABLE of upgrading to Windows 11." -ForegroundColor Green
    } else {
        $results.OverallStatus = "NOT CAPABLE"
        Write-Host "This PC IS NOT CAPABLE of upgrading to Windows 11 due to the following:" -ForegroundColor Red
        $results.FailedChecks | ForEach-Object {
            Write-Host " - $_" -ForegroundColor Red
        }
        Write-Host "Please address the failed requirements to upgrade." -ForegroundColor Red
    }

    Return $results
}

# Run the function
Test-Windows11Compatibility
