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
    Date: July 9, 2025 (Updated for better error handling)
    Version: 1.1
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
        $processor = Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop
        $cores = $processor.NumberOfCores
        $logicalProcessors = $processor.NumberOfLogicalProcessors
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
        Write-Host "   Processor check: FAIL (Could not retrieve information: $($_.Exception.Message))" -ForegroundColor Red
    }

    # 2. RAM Check
    Write-Host "`n2. Checking RAM..." -ForegroundColor Yellow
    try {
        $ram = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop | Select-Object -ExpandProperty TotalPhysicalMemory
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
        Write-Host "   RAM check: FAIL (Could not retrieve information: $($_.Exception.Message))" -ForegroundColor Red
    }

    # 3. Storage Check (C: drive)
    Write-Host "`n3. Checking Storage (C: Drive)..." -ForegroundColor Yellow
    try {
        $drive = Get-PSDrive C -ErrorAction Stop | Select-Object -ExpandProperty Free
        $totalSize = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop).Size
        $totalSizeGB = [Math]::Round($totalSize / 1GB)
        $freeSpaceGB = [Math]::Round($drive / 1GB)
        Write-Host "   - C: Drive Total Size: $($totalSizeGB) GB"
        Write-Host "   - C: Drive Free Space: $($freeSpaceGB) GB"

        if ($totalSizeGB -ge 64) {
            $results.Storage = "PASS"
            Write-Host "   Storage check: PASS" -ForegroundColor Green
        } else {
            $results.FailedChecks += "Storage"
            Write-Host "   Storage check: FAIL (C: drive requires 64 GB or larger)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "Storage"
        Write-Host "   Storage check: FAIL (Could not retrieve information: $($_.Exception.Message))" -ForegroundColor Red
    }

    # 4. Secure Boot Check
    Write-Host "`n4. Checking Secure Boot..." -ForegroundColor Yellow
    try {
        # This check is sensitive to the WMI namespace existing and permissions.
        # Adding -ErrorAction Stop ensures the catch block is triggered on an error.
        $secureBootInfo = Get-CimInstance -Namespace root\Security\Boot -ClassName SecurityFirmwareTpmInfo -ErrorAction Stop

        if ($secureBootInfo.SecureBootEnabled) {
            $results.SecureBoot = "PASS"
            Write-Host "   Secure Boot check: PASS (Enabled)" -ForegroundColor Green
        }
        else {
            $results.FailedChecks += "SecureBoot"
            Write-Host "   Secure Boot check: FAIL (Not enabled. Check BIOS/UEFI settings.)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "SecureBoot"
        # Specifically check for "Invalid namespace" or other common errors.
        if ($_.Exception.Message -match "Invalid namespace" -or $_.Exception.HResult -eq "0x8004100e") {
            Write-Host "   Secure Boot check: FAIL (Could not determine status. Likely not in UEFI mode or namespace missing. Error: $($_.Exception.Message))" -ForegroundColor Red
        } else {
            Write-Host "   Secure Boot check: FAIL (Could not determine status. Error: $($_.Exception.Message))" -ForegroundColor Red
        }
    }

    # 5. TPM Check (Trusted Platform Module)
    Write-Host "`n5. Checking TPM..." -ForegroundColor Yellow
    try {
        # Adding -ErrorAction Stop ensures the catch block is triggered on an error.
        $tpm = Get-CimInstance -ClassName Win32_Tpm -Namespace root\CIMV2\Security\MicrosoftTpm -ErrorAction Stop
        if ($tpm) {
            $tpmVersion = "$($tpm.SpecVersionMajor).$($tpm.SpecVersionMinor)"
            $tpmEnabled = $tpm.Enabled
            $tpmActivated = $tpm.Activated
            Write-Host "   - TPM Present: Yes"
            Write-Host "   - TPM Version: $($tpmVersion)"
            Write-Host "   - TPM Enabled: $($tpmEnabled)"
            Write-Host "   - TPM Activated: $($tpmActivated)"

            # Ensure version is correctly parsed for comparison
            $tpmVersionFloat = [System.Version]$tpmVersion

            if ($tpmEnabled -and $tpmActivated -and $tpmVersionFloat -ge [System.Version]"2.0") {
                $results.TPM = "PASS"
                Write-Host "   TPM check: PASS (TPM 2.0 enabled and activated)" -ForegroundColor Green
            } else {
                $results.FailedChecks += "TPM"
                Write-Host "   TPM check: FAIL (Requires TPM 2.0 enabled and activated. Check BIOS/UEFI settings.)" -ForegroundColor Red
            }
        } else { # This else should technically not be hit if -ErrorAction Stop works, but good as a fallback
            $results.FailedChecks += "TPM"
            Write-Host "   TPM check: FAIL (TPM not found or accessible.)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "TPM"
        # Common TPM errors are "Provider is not capable of the attempted operation" or not found.
        Write-Host "   TPM check: FAIL (Could not retrieve TPM information. Ensure TPM is enabled in BIOS/UEFI. Error: $($_.Exception.Message))" -ForegroundColor Red
    }

    # 6. Graphics Card Check
    Write-Host "`n6. Checking Graphics Card..." -ForegroundColor Yellow
    try {
        $graphicsCard = Get-CimInstance -ClassName Win32_VideoController -ErrorAction Stop
        $directXVersion = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\DirectX -ErrorAction SilentlyContinue).Version # Use SilentlyContinue to not error if key isn't perfect
        $wddmDetected = $false
        # A more robust check for WDDM would involve DriverStore queries, but this WMI class doesn't expose it directly.
        # We'll infer from the reported driver version and basic capabilities.
        if ($graphicsCard.DriverVersion -match "^(10\.0|9\.)" -and $graphicsCard.AdapterCompatibility -notmatch "Microsoft Hyper-V" ) { # Basic check for modern Windows drivers
             $wddmDetected = $true # Implies WDDM 2.0 if it's a modern driver and not Hyper-V
        }
        
        Write-Host "   - Graphics Card Name: $($graphicsCard.Name)"
        Write-Host "   - DirectX Version (from Registry): $($directXVersion)"
        Write-Host "   - Driver Version (from WMI): $($graphicsCard.DriverVersion)"
        Write-Host "   - Adapter Compatibility: $($graphicsCard.AdapterCompatibility)"


        # A basic check: If DirectX 12 is present and there's a modern driver and not a generic Hyper-V adapter
        # Note: DirectX 12 check from registry is not foolproof. The actual graphics hardware must support DX12.
        if (($directXVersion -match "12" -or $directXVersion -ge "10") -and $wddmDetected -and ($graphicsCard.CurrentBitsPerPixel -ne $null -or $graphicsCard.CurrentHorizontalResolution -ne $null)) {
            $results.Graphics = "PASS"
            Write-Host "   Graphics card check: PASS (DirectX 12 capable with WDDM 2.0-like driver detected)" -ForegroundColor Green
        } else {
            $results.FailedChecks += "Graphics"
            Write-Host "   Graphics card check: FAIL (Requires DirectX 12 compatible with WDDM 2.0 driver. Current DX: $($directXVersion). Driver indicates modern: $($wddmDetected). Adapter: $($graphicsCard.AdapterCompatibility))" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "Graphics"
        Write-Host "   Graphics card check: FAIL (Could not retrieve information: $($_.Exception.Message))" -ForegroundColor Red
    }

    # 7. Display Check
    Write-Host "`n7. Checking Display..." -ForegroundColor Yellow
    try {
        $monitor = Get-CimInstance -ClassName Win32_DesktopMonitor -ErrorAction Stop
        $screenWidth = $monitor.ScreenWidth
        $screenHeight = $monitor.ScreenHeight
        $bitsPerPixel = $monitor.BitsPerPixel

        Write-Host "   - Display Resolution: $($screenWidth)x$($screenHeight)"
        Write-Host "   - Bits Per Pixel: $($bitsPerPixel)"

        # 720p is 1280x720, so checking for minimum width or height
        if (($screenWidth -ge 1280 -and $screenHeight -ge 720) -and ($bitsPerPixel -ge 24)) {
            $results.Display = "PASS"
            Write-Host "   Display check: PASS" -ForegroundColor Green
        } else {
            $results.FailedChecks += "Display"
            Write-Host "   Display check: FAIL (Requires 720p+ resolution (e.g., 1280x720), 9+ inch diagonal, 8 bits/color channel (min 24 bits/pixel). Current: $($screenWidth)x$($screenHeight), $($bitsPerPixel) BPP)" -ForegroundColor Red
        }
    }
    catch {
        $results.FailedChecks += "Display"
        Write-Host "   Display check: FAIL (Could not retrieve information: $($_.Exception.Message))" -ForegroundColor Red
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
