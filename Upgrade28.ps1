param(
    [Parameter(Mandatory=$false, HelpMessage="Specify path for the Windows 11 ISO to be downloaded")]
    [ValidateScript({Test-Path $_ -IsValid})]
    [string]$DownloadPath = "C:\Windows\Temp\Win11_24H2.iso",

    [Parameter(Mandatory=$false, HelpMessage="Specify Arguments to run with setup.exe")]
    [string]$Arguments = "/auto upgrade /DynamicUpdate Disable /quiet"
)

# Fixed Microsoft ISO URL
$DownloadURL = "https://go.microsoft.com/fwlink/?linkid=2289031&clcid=0x4009&culture=en-in&country=in"

Write-Host "Downloading ISO from $DownloadURL to $DownloadPath"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($DownloadURL, $DownloadPath)

Write-Host "Mounting ISO File"
$vol = Mount-DiskImage -ImagePath $DownloadPath -PassThru |
    Get-DiskImage | 
    Get-Volume
$setup = '{0}:\setup.exe' -f $vol.DriveLetter

Write-Host "Starting Windows 11 Upgrade with arguments: $Arguments"
Start-Process cmd.exe -Wait -ArgumentList "/c `"$setup`" $Arguments"

Write-Host "Finished installing - if errors occur, try running without the /quiet command"
