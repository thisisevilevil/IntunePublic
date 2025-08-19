function getmajoredgeversion {
#This function can be used if we want to make sure devices are running the latest major edge version
$targetversion = '138' #Target major version we want to be at - Adjust this based on your needs

#Get Major edgeversion
$edgeversion = (Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo.ProductVersion
$splitedgeversion = $edgeversion.Split(".")
[int]$global:majoredgeversion = $splitedgeversion[0]

}

if ($majoredgeversion -ge $targetversion) {
    Write-host "Edge version is already newer than the target version specified in the script - no actions performed"
}
else {Write-host "Edge version is not up-to-date - Running Edge update now"
Start-Process -FilePath "C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe" -argumentlist "/silent /install appguid={56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}&appname=Microsoft%20Edge&needsadmin=True"
}



