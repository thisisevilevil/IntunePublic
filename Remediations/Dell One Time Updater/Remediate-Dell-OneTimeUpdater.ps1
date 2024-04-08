<#
Just a very simple driver updater script for Dell Devices :)

Can be used a PowerShell script, Remediation, GPO Logon script, scheduled task, SCCM Script etc. etc.

You need to have Dell Command Update installed on your devices, otherwise it will attempt to download and install it automatically. However note that Dell changes this often, so I would recommend
Changing the $uri variable to a self-hosted instance of DCU will be better.

Otherwise it will leave a log file after each time it runs under C:\windows\Logs called dcucli_applyupdates_<currentdate>.log for diagnostic purposes

Mads Johansen / mcj@apento.com
#>

if (!(($(gwmi win32_bios).Manufacturer -like '*Dell*'))) {Write-output "This is not a dell Device. unable to continue" ; exit 1}

$currentdate = Get-Date -format 'ddMMyyyy_HHmmss'
$dcucli = "${env:ProgramFiles}\Dell\CommandUpdate\dcu-cli.exe"

if (!(test-path $dcucli)) {
$uri = 'https://dl.dell.com/FOLDER11201586M/1/Dell-Command-Update-Windows-Universal-Application_0XNVX_WIN_5.2.0_A00.EXE'
Write-Host "DCU Cli doesn't seem to be present.. Attempting to download and install now.."
Invoke-WebRequest -uri $uri -outfile 'C:\Windows\temp\dcu52.exe' 
Start-Process "C:\Windows\Temp\dcu52.exe" -ArgumentList '/s' -Wait
Start-Sleep -Seconds 10
}

#Apply all updates if any is found - including BIOS
Start-Process $dcucli -ArgumentList "/ApplyUpdates -outputlog=C:\Windows\Logs\dcucli_applyupdates_$currentdate.log" -Verbose -Wait