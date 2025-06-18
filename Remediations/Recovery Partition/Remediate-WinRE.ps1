#Requires -RunAsAdministrator
$Win10_22H2WinRE = '<InsertLinkToBlobStorage>'
$Win11_22H2WinRE = '<InsertLinkToBlobStorage>'
$Win11_23H2WinRE = '<InsertLinkToBlobStorage>'
$Win11_24H2WinRE = '<InsertLinkToBlobStorage>'
$recoverywim = 'C:\Windows\System32\Recovery\WinRE.wim'

Start-Transcript C:\Windows\Logs\Remediate-Recoverypartition.log -Force

#Test if the existing recovery WIM file exists. Otherwise download it from blob
if (!(Test-path $recoverywim))
    {
    $build = (Get-CimInstance Win32_OperatingSystem).BuildNumber
    switch ($build) {
        '19045' {$recoverywimpath = $Win10_22H2WinRE}
        '22621' {$recoverywimpath = $Win11_22H2WinRE}
        '22631' {$recoverywimpath = $Win11_23H2WinRE}
        '26100' {$recoverywimpath = $Win11_24H2WinRE}
    }
    Write-output "Recovery WIM file not located locally - Proceeding to download from $recoverywimpath"
    Try {
        Invoke-WebRequest -uri $recoverywimpath -OutFile $recoverywim -Verbose
    } Catch {
        Write-Output "Unable to download Recovery WIM.. exiting."
        exit 1
    }
}

#Write Diskpart script to C:\Windows\Logs\WinReFix - This also has to be encoded to ASCII otherwise it will fail
if (!(Test-path C:\Windows\Logs\WinREFix)) {New-Item C:\Windows\Logs\WinREFix -ItemType Directory}
$diskpart1 = @'
sel vol c
shrink desired=1000 minimum=950
cre par pri size=1000 id=de94bba4-06d1-4d40-a16a-bfd50179d6ac
format fs=ntfs quick label=WinRE
assign letter=q
gpt attributes=0x8000000000000001
'@ | out-file -FilePath "C:\Windows\Logs\WinREFix\diskpart1.txt" -Encoding ASCII
Diskpart /s C:\Windows\Logs\WinREFix\diskpart1.txt >> C:\Windows\Logs\WinREFix\DiskpartWinReFix.log

if (!(Test-path Q:\)) {
    Write-output "Q:\ is not accessible.. partition shrinking or creation may have failed."
    exit 1
}


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
'@ | out-file -FilePath "C:\Windows\Logs\WinREFix\diskpart2.txt" -Encoding ASCII
Diskpart /s C:\Windows\Logs\WinREFix\diskpart2.txt >> C:\Windows\Logs\WinREFix\DiskpartWinReFix.log

#final check for Recovery environment is working
$recoveryinfo = reagentc /info
if ($recoveryinfo -like '*Disabled*') {
Write-Output "Recovery partition is still not working :("

#Specific error checking - Return error if corruption is detected (Only works if the windows version if english)
$corruptvolumecheck = Select-String -Path "C:\Windows\Logs\WinREFix\DiskpartWinReFix.log" -Pattern 'The volume you have selected to shrink may be corrupted.' -ErrorAction SilentlyContinue
if ($corruptvolumecheck -like '*The volume you have selected to shrink may be corrupted*') {
Write-output "Corruption has been detected on the hard-drive. Attempting to remediate using chkdsk"
    if (!(Test-path C:\Windows\Logs\Remediate-RecoveryPartition_DiskCheckScheduled.dat)) {
    Suspend-BitLocker -MountPoint "C:" -RebootCount 1
    Start-Sleep -Seconds 5
    echo y|chkdsk c: /f /r /x
    New-Item C:\Windows\Logs\Remediate-RecoveryPartition_DiskCheckScheduled.dat
    exit 1
    }
        else {Write-output "Corruption has been detected on the hard-drive. A disk check is already commenced or already completed on this drive. If this message keeps appearing there might be a hardware issue" ; exit 1}
}

#Specific error checking - Return error if no available diskpace (Only works if the windows version if english)
$diskspacecheck = Select-String -Path "C:\Windows\Logs\WinREFix\DiskpartWinReFix.log" -Pattern 'The specified shrink size is too big and will cause the volume to be' -ErrorAction SilentlyContinue
if ($diskspacecheck -like '*The specified shrink size is too big and will cause the volume to be*') {
    if (!(Test-path C:\Windows\Logs\Remediate-RecoveryPartition_DiskCheckScheduled.dat)) {
        Suspend-BitLocker -MountPoint "C:" -RebootCount 1
        Start-Sleep -Seconds 5
        echo y|chkdsk c: /f /r /x
        New-Item C:\Windows\Logs\Remediate-RecoveryPartition_DiskCheckScheduled.dat
        exit 1
        }
            else {Write-output "Corruption has been detected on the hard-drive. A disk check is already commenced or already completed on this drive. If this message keeps appearing there might be a hardware issue" ; exit 1}
}

#No specific error found
exit 1

}
    else {
        Write-Output "Recovery environment has been fixed. Happy days :)"

        #Rename DiskpartWinReFix if it's already working
        if (Test-path C:\Windows\Logs\WinREFix\DiskpartWinReFix.log) {Rename-Item -Path C:\Windows\Logs\WinREFix\DiskpartWinReFix.log -NewName 'DiskpartWinReFix_Fixed.log'}
        exit
    }

Stop-transcript