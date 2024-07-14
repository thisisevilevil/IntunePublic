<#
Script to reset Windows Update component

Built using official Microsoft Documentation: https://learn.microsoft.com/en-us/troubleshoot/windows-client/deployment/additional-resources-for-windows-update

Mads Johansen / mcj@apento.com

#>

#Stop Services
Stop-Service bits -Force
Stop-Service wuauserv -Force
Stop-Service cryptsvc -Force

#Delete qmgr files
Remove-Item "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -Verbose

#rename windows update folders
Rename-Item "$env:windir\SoftwareDistribution\DataStore" -NewName DataStore.bak -Force
Rename-Item "$env:windir\SoftwareDistribution\Download" -NewName Download.bak -Force
Rename-Item "$env:windir\System32\catroot2" -NewName catroot2.bak -Force

#Reset BITS Service to default security descriptor
Start-Process sc.exe -ArgumentList "sdset bits D:(A;CI;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)" 
Start-Process sc.exe -ArgumentList "sdset wuauserv D:(A;;CCLCSWRPLORC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)"

#Re-register a bunch of dll files for windows update
Set-Location C:\Windows\System32
regsvr32.exe atl.dll
regsvr32.exe urlmon.dll
regsvr32.exe mshtml.dll
regsvr32.exe shdocvw.dll
regsvr32.exe browseui.dll
regsvr32.exe jscript.dll
regsvr32.exe vbscript.dll
regsvr32.exe scrrun.dll
regsvr32.exe msxml.dll
regsvr32.exe msxml3.dll
regsvr32.exe msxml6.dll
regsvr32.exe actxprxy.dll
regsvr32.exe softpub.dll
regsvr32.exe wintrust.dll
regsvr32.exe dssenh.dll
regsvr32.exe rsaenh.dll
regsvr32.exe gpkcsp.dll
regsvr32.exe sccbase.dll
regsvr32.exe slbcsp.dll
regsvr32.exe cryptdlg.dll
regsvr32.exe oleaut32.dll
regsvr32.exe ole32.dll
regsvr32.exe shell32.dll
regsvr32.exe initpki.dll
regsvr32.exe wuapi.dll
regsvr32.exe wuaueng.dll
regsvr32.exe wuaueng1.dll
regsvr32.exe wucltui.dll
regsvr32.exe wups.dll
regsvr32.exe wups2.dll
regsvr32.exe wuweb.dll
regsvr32.exe qmgr.dll
regsvr32.exe qmgrprxy.dll
regsvr32.exe wucltux.dll
regsvr32.exe muweb.dll
regsvr32.exe wuwebv.dll

#Netsh winsock reset
netsh winsock reset

#restart all windows update services
Start-Service bits
Start-Service wuauserv   
Start-Service cryptsvc