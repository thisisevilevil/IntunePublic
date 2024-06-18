$currentdate = Get-Date -format 'ddMMyyyy_HHmmss'
$dir = "C:\Windows\Logs\Win11_Update_$currentdate"
New-Item $dir -ItemType Directory
$webClient = New-Object System.Net.WebClient
$url = 'https://go.microsoft.com/fwlink/?linkid=2171764'
$file = "$($dir)\Windows11InstallationAssistant.exe"
$webClient.DownloadFile($url,$file)
Start-Process -FilePath $file -Wait -ArgumentList "/quietinstall /skipeula /auto upgrade /copylogs $dir"