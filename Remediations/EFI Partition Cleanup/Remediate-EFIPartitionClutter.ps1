mountvol Y: /s
$driveletter = 'Y:'
$hpstaging = 'C:\HPStuff'

# Check if the drive exists
if (-not (Test-Path Y:\)) {
    Write-Error "Drive Y:\ not found."
    exit 1
}

# Get drive info using .NET
$driveInfo = New-Object -TypeName System.IO.DriveInfo -ArgumentList $driveLetter
$freeSpaceold = $driveInfo.AvailableFreeSpace

Write-output "Free space before beginning: $freespaceold"

if (!(Test-Path $hpstaging)) {New-Item $hpstaging -ItemType Directory}

if (Test-Path Y:\EFI\HP\DEVFW) {
    Write-output "DevFW folder located on EFI Partition.. moving this to $hpstaging"
    Move-Item Y:\EFI\HP\DEVFW -Destination $hpstaging -Force
    }

if (Test-Path Y:\EFI\HP\Previous) {
    Write-output "Old HP Firmware files located on EFI Partition.. proceeding to remediation.."
    Move-Item Y:\EFI\HP\Previous -Destination $hpstaging -Force
    }

#Cleanup font files for good measure
gci Y:\EFI\Microsoft\Boot\Fonts -Filter *.ttf | Remove-Item -Force

#New status
$freeSpace = $driveInfo.AvailableFreeSpace
Write-output "Free space before: $freespaceold --- Free space after cleanup: $freespace"

mountvol Y: /d
