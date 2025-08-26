$scriptContent = @"
\$dir = 'C:\Win11Upgrade'
\$setupPath = Join-Path \$dir 'setup.exe'
\$logPath = 'C:\Install\WinSetup.log'

if (Test-Path \$setupPath) {
    Write-Output "Found setup.exe. Starting Enterprise upgrade..."
    Start-Process -FilePath \$setupPath -ArgumentList "/auto upgrade /quiet /noreboot /dynamicupdate disable /copylogs C:\Install" -WindowStyle Hidden
    Write-Output "Setup.exe launched successfully."
} else {
    Write-Output "setup.exe not found under \$dir"
    exit 1
}
"@
