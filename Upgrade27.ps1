param(
    [Parameter(Mandatory=$false, HelpMessage="Specify path for the Windows 11 ISO to be downloaded")]
    [ValidateScript({Test-Path $_ -IsValid})]
    [string]$DownloadPath = "C:\Windows\Temp\Win11_24H2.iso",

    [Parameter(Mandatory=$false, HelpMessage="Specify Arguments to run with setup.exe")]
    [string]$Arguments = "/auto upgrade /DynamicUpdate Disable /quiet"
)

# Fixed Microsoft ISO URL
$DownloadURL = "https://software.download.prss.microsoft.com/dbazure/Win11_24H2_English_x64.iso?t=85992931-c170-4dc5-b2c7-4cc29022c4ad&P1=1756238428&P2=601&P3=2&P4=gkdwM2nzsXREy8AgSnR%2fHSLaKF0c5b0PQ4q1XuVAass0lQCPiHmoEIg9KIglhuBeAiV%2faf%2fISHQ2iAnvaxMGjW%2fcxPm%2bcUGZTreUgiblD1G0Z7TT6gbiHFbqImDe4NqKL6i5z%2bia6K4zRnpedsKEcZzNoXL23%2fsf%2bBEKtgHRsBwiHkXnD%2bXevcSLips2GEKBnXOkwe7l7zI%2b%2fDWY56yedgesonQ%2f2X4KeupVOPn%2f5f6D2Hjk45o7iPCPts1bAffRljZO8EbtvFdtu68UlIw0gtrUaStPHiPzOUvhzR%2ffdeswAQ%2bJCiLRo1guNf0jqZR4sRXY%2fkEHiGJKDZ5yIgvahw%3d%3d"

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
