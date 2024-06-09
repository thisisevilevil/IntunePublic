#Requires -RunAsAdministrator
$Win21H2WinRE = 'InsertLinktoDownloadWinREImage'
$Win22H2WinRE = 'InsertLinktoDownloadWinREImage'
$recoverywim = 'C:\Windows\System32\Recovery\WinRE.wim'

Start-Transcript C:\Logs\Remediate-Recoverypartition.log -Force

#Test if the existing recovery WIM file exists. Otherwise download it from blob
if (!(Test-Path $recoverywim)) {

    #Fetch OS version to get the correct WIM file - exit if not running Win10 21H2 or 22H2
    if ($(gwmi win32_operatingsystem).BuildNumber -lt '19044') {Write-output "We only suport Windows 10 21H2 and 22H2, unable to continue" ; exit 1}
    if ($(gwmi win32_operatingsystem).BuildNumber -gt '19045') {Write-output "We only suport Windows 10 21H2 and 22H2, unable to continue" ; exit 1}

    if ($(gwmi win32_operatingsystem).BuildNumber -eq '19045') {$recoverywimuri = $Win22H2WinRE}
    if ($(gwmi win32_operatingsystem).BuildNumber -eq '19044') {$recoverywimuri = $Win21H2WinRE}
        Try { 
        Invoke-WebRequest -uri $recoverywimuri -OutFile $recoverywim
        }
            Catch {Write-Output "Recovery WIM file doesn't exist in $recoverywim and we are unable to download it from the designated URL.. :( unable to continue"
            exit 1
            }

    }

#Write Diskpart script to C:\Logs\WinReFix - This also has to be encoded to ASCII otherwise it will fail
if (!(Test-path C:\Logs\WinREFix)) {New-Item C:\Logs\WinREFix -ItemType Directory}
$diskpart1 = @'
sel vol c
shrink desired=665 minimum=650
cre par pri size=665 id=de94bba4-06d1-4d40-a16a-bfd50179d6ac
format fs=ntfs quick label=WinRE
assign letter=q
gpt attributes=0x8000000000000001
'@ | out-file -FilePath "C:\Logs\WinREFix\diskpart1.txt" -Encoding ASCII
Diskpart /s C:\Logs\WinREFix\diskpart1.txt >> C:\Logs\WinREFix\DiskpartWinReFix.log

#Adding a timeout of 15 seconds as pr. recommendation from Microsoft as we are not able to run diskpart scripts in quick succession
Start-Sleep -Seconds 15

#Copy WinRE Wim to new WinRE environment and set Custom WinRE Path - Then we enable WinRE again
New-Item "Q:\Recovery\WindowsRE" -ItemType Directory
Copy-Item $recoverywim -Destination "Q:\Recovery\WindowsRE" -Force
ReAgentC /SetREImage /Path Q:\Recovery\WindowsRE
ReAgentC /enable
Start-Sleep -Seconds 5

#Remove temporary drive letter from WinRE partition using another diskpart script
$diskpart2 = @'
sel vol q
remove
'@ | out-file -FilePath "C:\Logs\WinREFix\diskpart2.txt" -Encoding ASCII
Diskpart /s C:\Logs\WinREFix\diskpart2.txt >> C:\Logs\WinREFix\DiskpartWinReFix.log

#final check for Recovery environment is working
$recoveryinfo = reagentc /info
if ($recoveryinfo -like '*Disabled*') {
Write-Output "Recovery partition is still not working :("

#Specific error checking - Return error if corruption is detected
$corruptvolumecheck = Select-String -Path "C:\Logs\WinREFix\DiskpartWinReFix.log" -Pattern 'The volume you have selected to shrink may be corrupted.' -ErrorAction SilentlyContinue
if ($corruptvolumecheck -like '*The volume you have selected to shrink may be corrupted*') {
Write-output "Corruption has been detected on the hard-drive. Attempting to remediate using chkdsk"
    if (!(Test-path C:\Logs\Remediate-RecoveryPartition_DiskCheckScheduled.dat)) {
    Suspend-BitLocker -MountPoint "C:" -RebootCount 1
    Start-Sleep -Seconds 5
    echo y|chkdsk c: /f /r /x
    New-Item C:\Logs\Remediate-RecoveryPartition_DiskCheckScheduled.dat
    exit 1
    }
        else {Write-output "Corruption has been detected on the hard-drive. A disk check is already commenced or already completed on this drive. If this message keeps appearing there might be a hardware issue" ; exit 1}
}

#Specific error checking - Return error if no available diskpace
$diskspacecheck = Select-String -Path "C:\Logs\WinREFix\DiskpartWinReFix.log" -Pattern 'The specified shrink size is too big and will cause the volume to be' -ErrorAction SilentlyContinue
if ($diskspacecheck -like '*The specified shrink size is too big and will cause the volume to be*') {
    if (!(Test-path C:\Logs\Remediate-RecoveryPartition_DiskCheckScheduled.dat)) {
        Suspend-BitLocker -MountPoint "C:" -RebootCount 1
        Start-Sleep -Seconds 5
        echo y|chkdsk c: /f /r /x
        New-Item C:\Logs\Remediate-RecoveryPartition_DiskCheckScheduled.dat
        exit 1
        }
            else {Write-output "Corruption has been detected on the hard-drive. A disk check is already commenced or already completed on this drive. If this message keeps appearing there might be a hardware issue" ; exit 1}
}

#No specific error found
exit 1

}
    else {
        Write-Output "Recovery environment has been fixed. Happy days :)"

        #Delete DiskpartWinReFix if it's already working
        if (Test-path C:\Logs\WinREFix\DiskpartWinReFix.log) {Rename-Item -Path C:\Logs\WinREFix\DiskpartWinReFix.log -NewName 'DiskpartWinReFix_Fixed.log'}
        exit
    }

Stop-transcript