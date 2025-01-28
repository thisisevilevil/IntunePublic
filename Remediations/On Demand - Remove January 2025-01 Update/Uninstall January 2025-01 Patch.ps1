<#

Script for removing the January 2025-01 update for Windows 11
Cause: Webcam/Bluetooth might stop working on certain devices. 
Reference: https://www.windowslatest.com/2025/01/26/windows-11-24h2-kb5050009-issues-break-audio-camera-kb5050021-affected-too/

Can be used as an on-demand remediation or also as a one-off platform script. Inspiration: https://evil365.com/intune/FunWith-Remediations/

Remember to adjust the reboot timer in the bottom of the script to suit your environment

#>

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