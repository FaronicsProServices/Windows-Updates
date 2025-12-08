$dir = 'C:\temp\Win11'
mkdir $dir
$webClient = New-Object System.Net.WebClient
$url = 'https://download.microsoft.com/download/db8267b0-3e86-4254-82c7-a127878a9378/Windows11InstallationAssistant.exe'
$file = "$($dir)\Windows11InstallationAssistant.exe"
$webClient.DownloadFile($url,$file)
Start-Process -FilePath $file -ArgumentList "/quietinstall /skipeula /auto upgrade /NoRestartUI /copylogs $dir"
