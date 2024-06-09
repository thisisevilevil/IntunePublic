<#
ProActive Remediation script to migrate from MBAM Bitlocker to AzureAD Bitlocker for existing devices

This is the remediation script.

1.0 Mads Johansen / APENTO 08/02/2023: Initial release

#>

#Start Transcript
$currentdate = Get-Date -format 'ddMMyyyy_HHmmss'
Start-Transcript C:\Logs\MBAMMigration_$currentdate.log

#Get Bitlocker volume for system drive
$BLV = Get-BitLockerVolume -MountPoint $env:SystemDrive
if (($blv).VolumeStatus -eq 'FullyDecrypted') {Write-output "The OS Drive is not bitlocker encrypted.." ; exit 1}

#Find the recovery password protector. If it doesn't exist, we add a new one
$protectors = $blv.KeyProtector | Where {$_.KeyProtectorType -eq 'RecoveryPassword'}
if ($protectors) {
    $keyprotectorID = $protectors.KeyProtectorID
}
    else {Write-output "Recovery password not found.. proceeding to generate new recovery password"
        Try {Add-Bitlockerkeyprotector -MountPoint $env:systemdrive -RecoveryPasswordProtector -ErrorAction Stop | out-null
        Start-Sleep -Seconds 2
        $BLV = Get-BitLockerVolume -MountPoint $env:SystemDrive
        $protectors = $blv.KeyProtector | Where {$_.KeyProtectorType -eq 'RecoveryPassword'}
        $KeyProtectorID = $protectors.KeyProtectorID}
            Catch {Write-output "something went wrong trying to add the recovery password on this device.. please investigate." ; exit 1}
    }

#Finally attempt to backup to AzureAD
Try {BackupToAAD-BitLockerKeyProtector -MountPoint "$($env:SystemDrive)" -KeyProtectorId $keyprotectorID -ErrorAction Stop}
    Catch {Write-output "Something went wrong trying to backup the recovery key to AzureAD.. please investigate" ; exit 1}

#Remove MBAM Agent after everything completed
$mbam = gwmi win32_product | Where {$_.Name -eq 'MDOP MBAM'} | Select -ExpandProperty IdentifyingNumber
if (!($mbam)) {Write-host "No MBAM Agent found on this device, no need to uninstall"}
    else {
        Try {Start-process msiexec -Wait -Argumentlist "/X $mbam /qn"}
            Catch {Write-output "Failed to remove the MBAM Agent... please investigate" ; exit 1}
        }

#MBAM Migration complete
Write-output "MBAM Migration completed sucessfully"
New-item C:\Logs\MBAMtoAzureMigrationComplete.dat -Force
Stop-Transcript
