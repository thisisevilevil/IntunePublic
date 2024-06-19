#General Variables
$dir = "C:\Windows\temp"
$webClient = New-Object System.Net.WebClient
$url = 'https://go.microsoft.com/fwlink/?linkid=2171764'
$file = "$($dir)\Windows11InstallationAssistant.exe"

#Download Windows 11 Update assistant if it doesn't exist in C:\windows\temp
if (!(Test-Path $file)) {Write-host "Downloading Windows 11 Installation assistant from the interwebz"} 
{
$webClient.DownloadFile($url,$file) 
}

#Start the Windows 11 Upgrade Assistant
Start-Process -FilePath $file -Wait -ArgumentList "/quietinstall /skipeula /auto upgrade"