$dir = "C:\Windows\temp"
$webClient = New-Object System.Net.WebClient
$url = 'https://go.microsoft.com/fwlink/?linkid=2171764'
$file = "$($dir)\Windows11InstallationAssistant.exe"

if (!(Test-Path $file)) {Write-host "Downloading Windows 11 Installation assistant from the interwebz"} 
{
$webClient.DownloadFile($url,$file) 
}

Start-Process -FilePath $file -Wait -ArgumentList "/quietinstall /skipeula /auto upgrade"