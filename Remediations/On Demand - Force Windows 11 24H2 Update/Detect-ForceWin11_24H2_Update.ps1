$buildnumber = (gcim win32_operatingsystem).BuildNumber
if (!($buildnumber -eq '26100')) {
Write-output "Windows 11 24H2 is not installed on this device.. proceeding to remediation.."
exit 1
}
    else {Write-output "Windows 11 24H2 already installed on this device.. no actions performed"}