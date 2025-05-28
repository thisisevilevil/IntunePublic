#Install healthcheck app if it's missing
$appcheck = gwmi win32_product | Where {$_.Name -eq 'Windows PC Health Check'}
if (!($appcheck)) {
$dir = "C:\Windows\TEMP"
$url2 = 'https://aka.ms/GetPCHealthCheckApp'
$file2 = "$($dir)\Healtcheckapp.msi"
$webclient = New-Object System.Net.WebClient
$webClient.DownloadFile($url2,$file2)
Start-Process -FilePath msiexec -ArgumentList "/I $file2 /qn"
}

#Start Windows 11 upgrade silently
$currentdate = Get-Date -format 'ddMMyyyy_HHmmss'
$dir = "C:\Windows\TEMP\Win11_24H2_Update_$currentdate"
New-Item $dir -ItemType Directory
$webClient = New-Object System.Net.WebClient
$url = 'https://go.microsoft.com/fwlink/?linkid=2171764'
$file = "$($dir)\Windows11InstallationAssistant.exe"
$webClient.DownloadFile($url,$file)
Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /copylogs $dir'
