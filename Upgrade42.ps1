$SetupPath = "C:\Win11Upgrade\sources\setupprep.exe"
$Arguments = "/product server /auto upgrade /quiet /noreboot /dynamicupdate disable /migratedrivers none /eula accept /uninstall disable /compat ignorewarning /copylogs C:\Install\WinSetup.log"

Write-Host "Launching Windows Server upgrade..."

# Start setupprep.exe
$proc = Start-Process -FilePath $SetupPath -ArgumentList $Arguments -PassThru

# Wait for initial setupprep.exe exit
$proc.WaitForExit()

Write-Host "Initial setupprep.exe process exited. Monitoring all upgrade processes..."

# Loop until all setup-related processes are gone
do {
    Start-Sleep -Seconds 30
    $running = Get-Process | Where-Object { $_.ProcessName -match "setup|setupprep|setuphost|setupplatform" }
} while ($running)

Write-Host "Upgrade process has fully completed."
