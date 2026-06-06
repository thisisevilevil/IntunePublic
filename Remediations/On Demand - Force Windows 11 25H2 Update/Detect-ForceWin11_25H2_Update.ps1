$buildnumber = (gcim win32_operatingsystem).BuildNumber
if (!($buildnumber -eq '26200')) {
Write-output "Windows 11 25H2 is not installed on this device.. proceeding to remediation.."
exit 1
}
    else {Write-output "Windows 11 25H2 already installed on this device.. no actions performed"}