$buildnumber = (Get-Computerinfo).WindowsUBR

if ($buildnumber -lt '6575') {
Write-output "ESU patches not correctly processing.. proceeding to remediation.."
exit 1
    else {Write-output "ESU patches correctly installed on this device.. no actions performed"}
}