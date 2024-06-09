<#
ProActive Remediation script to migrate from MBAM Bitlocker to AzureAD Bitlocker for existing devices

This is the detection script

1.0 Mads Johansen / APENTO 08/02/2023: Initial release

#>

#Check if we are running on an Amazon workspace
if ($(gwmi win32_bios).Manufacturer -eq 'Xen') {Write-output "This is an Amazon workspace. We cannot run here. No further actions perfomed" ; exit}

#Initial TPM Check before we continue
if ((Get-Tpm).TpmPresent -eq $false) {Write-output "This device has no TPM. We can't do anything about this yet" ; exit 1}

#Check if control file exists. If it doesn't, time to do our thing otherwise we exit
$controlfile = "C:\Logs\MBAMtoAzureMigrationComplete.dat"
if (!(Test-path $controlfile)) {
    Write-output "Control file not located.. proceeding to remediation" ; exit 1
}
    else {Write-output "Control file located under C:\logs - We have already been here. Doing an extra check for the MBAM Agent"
    #Check if the MBAM Agent exist. If it does - Proceed to remediation
    $mbam = gwmi win32_product | Where {$_.Name -eq 'MDOP MBAM'}
    if ($mbam) {Write-output "MBAM Agent still detected after a migration.. proceeding to remediation" ; exit 1} 
        else {Write-output "MBAM to AzureAD Migration is complete. Happy days!"}   
    }