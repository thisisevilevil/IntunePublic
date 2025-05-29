$recoveryinfo = reagentc /info
if ($recoveryinfo -like '*Enabled*') {     

    #Check if the Recovery environment is placed on the OS Partition, as it's not supported
    $osDriveLetter = ($env:SystemDrive).TrimEnd(":")
    $ospartition = (Get-Partition -DriveLetter $osDriveLetter).PartitionNumber
    $ospartitionnumber = "partition$ospartition"

    #Grab WinRE Partition info
    foreach ($line in $recoveryinfo) {
        if ($line -match "Windows RE location\s*:\s*(.+)") {
            $winRELocation = $matches[1].Trim()
        }
    }

    #Proceed to remediation if the WinRE environment is placed on the OS Disk, as it's not supported
    if ($winRELocation -like "*$ospartitionnumber*") {
        Write-output "WinRE is enabled, but the recovery bits is placed on the OS Disk... proceeding to remediation"
        exit 1
    }

    Write-output "Recovery environment is enabled on this device, all is good"
}

if ($recoveryinfo -like '*Disabled*') {Write-output "Recovery partition is not working :(" ; exit 1}