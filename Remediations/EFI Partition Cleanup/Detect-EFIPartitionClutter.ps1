#Set threshold in bytes (e.g., 50 MB)
$thresholdBytes = 50MB

#Mount the EFI Partition
$driveLetter = "Y:"
mountvol $driveLetter /s

#Check if the drive exists
if (-not (Test-Path $driveLetter)) {
    Write-Error "Drive $driveLetter not found."
    exit 1
}

#Get drive info using .NET
$driveInfo = New-Object -TypeName System.IO.DriveInfo -ArgumentList $driveLetter
$freeSpace = $driveInfo.AvailableFreeSpace

#Report results
if ($freeSpace -lt $thresholdBytes) {
    Write-Output "Low disk space on $driveLetter. Free: $([math]::Round($freeSpace / 1MB, 2)) MB"
    mountvol $driveLetter /d
    exit 1
} else {
    Write-Output "$driveLetter has sufficient free space: $([math]::Round($freeSpace / 1MB, 2)) MB"
    mountvol $driveLetter /d
    exit
}

