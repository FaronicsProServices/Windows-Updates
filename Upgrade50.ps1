$SetupExe = "C:\Win11Upgrade\setup.exe"
$SetupPrepExe = "C:\Win11Upgrade\sources\setupprep.exe"
$Arguments = "/product server /auto upgrade /quiet /noreboot /dynamicupdate disable /migratedrivers none /eula accept /uninstall disable /compat ignorewarning /showoobe none /copylogs C:\Install\WinSetup.log"

function Monitor-Upgrade {
    param([string]$ProcName)

    Write-Host "Monitoring upgrade processes..."
    do {
        Start-Sleep -Seconds 30
        $running = Get-Process | Where-Object { $_.ProcessName -match "setup|setupprep|setuphost|setupplatform" }
    } while ($running)

    Write-Host "All setup processes have completed."
}

if (Test-Path $SetupExe) {
    Write-Host "Found setup.exe, starting upgrade..."
    $proc = Start-Process -FilePath $SetupExe -ArgumentList $Arguments -PassThru -WorkingDirectory "C:\Win11Upgrade"
    $proc.WaitForExit()
    
    Monitor-Upgrade
}
elseif (Test-Path $SetupPrepExe) {
    Write-Host "setup.exe not found, falling back to setupprep.exe..."
    $proc = Start-Process -FilePath $SetupPrepExe -ArgumentList $Arguments -PassThru -WorkingDirectory "C:\Win11Upgrade\sources"
    $proc.WaitForExit()
    
    Monitor-Upgrade
}
else {
    Write-Host "ERROR: Neither setup.exe nor setupprep.exe were found in C:\Win11Upgrade."
    exit 1
}

Write-Host "Upgrade process finished."
