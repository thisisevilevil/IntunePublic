$build = (gcim win32_operatingsystem).BuildNumber

if ($build -eq '26100') {
    $packagename = 'Package_for_RollupFix~31bf3856ad364e35~amd64~~26100.2894.1.18' 
    Write-output "Windows 11 24h2 device detected.. attempting removing the January 2025-01 update"
    Remove-WindowsPackage -Online -PackageName $packagename -NoRestart
}

if ($build -eq '22631') {
    $packagename = 'Package_for_RollupFix~31bf3856ad364e35~amd64~~22621.4751.1.11' 
    Write-output "Windows 11 23H2 device detected.. attempting removing the January 2025-01 update"
    Remove-WindowsPackage -Online -PackageName $packagename -NoRestart
}

if ($build -eq '22621') {
    $packagename = 'Package_for_RollupFix~31bf3856ad364e35~amd64~~22621.4751.1.11' 
    Write-output "Windows 11 22H2 device detected.. attempting removing the January 2025-01 update"
    Remove-WindowsPackage -Online -PackageName $packagename -NoRestart
}


shutdown -r -t 900 -c "Webcam not detected fix: The uninstall of the latest Microsoft security patch will be attempted at the next system restart. Please restart this device at your earliest convenience"