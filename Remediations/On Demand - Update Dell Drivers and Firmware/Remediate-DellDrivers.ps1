<#
Just a very simple driver updater script for Dell Devices :)
Revision history

Mads Johansen / mcj@apento.com

#>

if (!(($(gwmi win32_bios).Manufacturer -like '*Dell*'))) {Write-output "This is not a dell Device. unable to continue" ; exit 1}

$currentdate = Get-Date -format 'ddMMyyyy_HHmmss'
$dcucli = "${env:ProgramFiles}\Dell\CommandUpdate\dcu-cli.exe"

if (!(test-path $dcucli)) {
Write-Host "DCU Cli doesn't seem to be present.. Attempting to download and install now.."
Invoke-WebRequest -uri 'https://dl.dell.com/FOLDER11563484M/1/Dell-Command-Update-Windows-Universal-Application_P83K5_WIN_5.3.0_A00.EXE' -outfile 'C:\Windows\temp\dcu53.exe' 
Start-Process "C:\Windows\Temp\dcu53.exe" -ArgumentList '/s' -Wait
Start-Sleep -Seconds 10
}

#Apply all updates if any is found - including BIOS
Start-Process $dcucli -ArgumentList "/ApplyUpdates -outputlog=C:\Windows\Logs\dcucli_applyupdates_$currentdate.log" -Verbose -Wait