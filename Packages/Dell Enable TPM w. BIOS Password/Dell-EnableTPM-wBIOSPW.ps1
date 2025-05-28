<#
Enable TPM on Dell-based devices that are password protected with a unique password.
Password should be placed in biospwlist.ini file in the following format <computername>;<Amount of characters in computername>;BIOSPassword

The amount of characters in the computername starts counting from 0, not 1. This is important to note, as this logic is used to match the computername with the corresponding password.

CCTK Logging will be placed under C:\Windows\Logs\DellEnableTPM.log for diagnostics

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

#Define function for looping through ini file with BIOS Passwords matched with computer names
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


#Check if any BIOS Passwords exists for the device
biospwlookup

#Validate pre-reqs to run script, otherwise we exit - NOTE: The CCTK binary is part of Dell Command | Endpoint Configure agent, you can download it from here: https://www.dell.com/support/kbdoc/en-us/000214308/dell-command-endpoint-configure-for-microsoft-intune
$cctk = 'C:\Program Files\Dell\EndpointConfigure\X86_64\cctk.exe'
if (!(Test-path $cctk)) {Write-output "Dell CCTK is missing. Please install Dell Command | Endpoint Configure or Dell Command | Monitor to continue" ; exit 1}
if (!($biospw)) {Write-host "No BIOS PW match found for $env:computername" ; exit 1}
}

#--- Activate TPM for newer models ---
if ($biospw) {Start-Process $cctk -Wait -ArgumentList "--tpm=on --ValSetupPwd=$biospw --logfile=C:\Windows\Logs\DellEnableTPM_wBIOSPW.log"}
    else {Start-Process $cctk -Wait -ArgumentList "--tpm=on --logfile=C:\Windows\Logs\DellEnableTPM.log"}


# --- Activate TPM for older models, manually add more as required, from line 93 and onwards (Consider replacing them instead, if possible) ---
function enableandactivatetpm {
# --- CONFIGURATION ---
$NewBIOSPassword = "evil365"  # Only used temporarily for TPM Activation reasons, changed as desired - Will be removed at a later stage
$ExportPath = "C:\Temp\DellTPMEnable.ini"

# --- SETUP ---
if (!(Test-Path $ExportPath)) {
    New-Item -Path (Split-Path $ExportPath) -ItemType Directory -Force
}

# Step 1: Set BIOS password (if not already set)
Set-Location $cctk
# Check if password is already set (returns errorlevel 0 if set)
$pwdCheck = & .\cctk.exe --setuppwd
if ($pwdCheck -eq 0) {
    Write-Output "BIOS password already set. Skipping password setup."
} else {
    & .\cctk.exe --setuppwd=$NewBIOSPassword
    Write-Output "BIOS password has been set."
}

# Step 2: Write TPM configuration to .ini
$TPMConfig = @"
[tpm]
tpm = enable
tpmactivation = activate
"@
$TPMConfig | Out-File -Encoding ascii -FilePath $ExportPath

# Step 3: Apply TPM config with password
Start-Process $cctk -Wait -ArgumentList "--import=$ExportPath --setuppwd=$NewBIOSPassword"
exit
}


#Enable and activate TPM for Latitude 7290's
if ($model -eq 'Latitude 7290') {
    Write-output "Latitude 7290 Detected. Enabling and activating TPM"
    enableandactivatetpm
    exit
    }

#Enable and activate TPM for Latitude 7280's
if ($model -eq 'Latitude 7280') {
    Write-output "Latitude 7280 Detected. Enabling and activating TPM"
    enableandactivatetpm
    exit
    }

#Enable and activate TPM for Latitude 5490's
if ($model -eq 'Latitude 5490') {
    Write-output "Latitude 5490 Detected. Enabling and activating TPM"
    enableandactivatetpm
    exit
    }
