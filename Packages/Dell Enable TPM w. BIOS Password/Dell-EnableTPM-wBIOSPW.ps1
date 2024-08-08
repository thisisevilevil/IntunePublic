<#
Enable TPM on Dell-based devices that are password protected with a unique password.
Password should be placed in biospwlist.ini file in the following format <computername>;<Amount of characters in computername>;BIOSPassword

The amount of characters in the computername starts counting from 0, not 1. This is important to note, as this logic is used to match the computername with the corresponding password.

CCTK Logging isbe placed under C:\Windows\Logs\DellEnableTPM.log for diagnostics

Example: 
TEST-535577;10;C00lP4$$w0rd
TEST-33333;9;M4sterBl4ster
TEST-4444;8;Rolf_er_ren

To deploy, package as Win32 app and use the following install string: 'Powershell.exe -ExecutionPolicy Bypass -File Dell-EnableTPM-wBIOSPW.ps1'
For detection, use a custom detection script and add the one I made available in my public Intune repo: https://github.com/thisisevilevil/IntunePublic

For a simpler non-Dell Detection that doesn't rely on CCTK, you can also use Get-TPM with PowerShell to detect if it's present.

Alternatively deploy with Proactive remediation, and you can place the biospwlist.ini file on a network share, blob storage or any location of your choosing. This might be a better alternative if your password file needs to change a lot.

This script can also be used for setting other settings using CCTK, when unique passwords pr. device is used, simply change the arguments in the start-process to fit your needs.

Script author: Mads Johansen / mcj@apento.com

#>

function biospwlookup {
#Loop on ini file based on devicename
$biospwlist = gc "$PsScriptRoot\biospwlist.ini"
foreach ($line in $biospwlist)
{
  $linearray = $line.Split(';')
  $cc = $linearray[0].Substring(0,$linearray[1]) 
  if($env:computername.Contains($cc))
    {
    $global:biospw = $linearray[2]
    Write-Host "A match has been found using $env:computername. BIOS PW for $env:computername is $biospw" -ForegroundColor Green
    }
}

if (!($biospw)) {Write-host "No BIOS PW match found for $env:computername"}
}

biospwlookup
$cctk = 'C:\Program Files\Dell\EndpointConfigure\X86_64\cctk.exe'
if (!(Test-path $cctk)) {Write-output "Dell CCTK is missing. Please install Dell Command | Endpoint Configure or Dell Command | Monitor to continue" ; exit 1}

if ($biospw) {Start-Process $cctk -Wait -ArgumentList "--tpm=on --ValSetupPwd=$biospw --logfile=C:\Windows\Logs\DellEnableTPM_wBIOSPW.log"}
    else {Start-Process $cctk -Wait -ArgumentList "--tpm=on --logfile=C:\Windows\Logs\DellEnableTPM.log"}
