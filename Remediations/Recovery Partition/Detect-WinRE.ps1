$recoveryinfo = reagentc /info
if ($recoveryinfo -like '*Enabled*') {Write-output "Recovery environment is ok on this device :)"; exit}

#Specific error checking - Return error if corruption on disk is detected
$corruptvolumecheck = Select-String -Path "C:\Logs\WinREFix\DiskpartWinReFix.log" -Pattern 'The volume you have selected to shrink may be corrupted' -ErrorAction SilentlyContinue
if ($corruptvolumecheck -like '*The volume you have selected to shrink may be corrupted*') {Write-output "OS Volume is corrupt, so we can't fix the recovery partition. We need to run a chkdsk. If this issue keeps re-occurring there might be a hardware error with this device" ; exit 1}

#Specific error checking - Return error if no available diskpace
$diskspacecheck = Select-String -Path "C:\Logs\WinREFix\DiskpartWinReFix.log" -Pattern 'The specified shrink size is too big and will cause the volume to be' -ErrorAction SilentlyContinue
if ($diskspacecheck -like '*The specified shrink size is too big and will cause the volume to be*') {Write-output "A disk space issue has been detected. Proceeding to remediation" ; exit 1}

if ($recoveryinfo -like '*Disabled*') {Write-output "Recovery partition is not working :(" ; exit 1}
    else {Write-output "Recovery environment is ok on this device :)"}