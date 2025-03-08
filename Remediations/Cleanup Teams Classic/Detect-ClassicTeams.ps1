$softwareinstalled = gwmi win32_product
$oldteamscheck = gci "C:\Users\*\AppData\Local\Microsoft\Teams\current\Teams.exe"


if ($softwareinstalled -like '*Microsoft Teams classic*') {
    Write-host "Microsoft Teams CLassic found on device or user.. proceeding to remediation"
    exit 1
}

if ($softwareinstalled -like '*Teams Machine-Wide Installer*') {
    Write-host "Teams Machine Wide installer found on device or user.. proceeding to remediation"
    exit 1
}

if ($oldteamscheck) {
    Write-output "old teams client detected in a userprofile. Information: $oldteamscheck.FullName"
    exit 1 
}

Write-output "No old teams version found on this device. No actions performed"