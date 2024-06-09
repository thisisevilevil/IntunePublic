if (!(($(gwmi win32_bios).Manufacturer -like '*Dell*'))) {Write-output "This is not a dell Device. unable to continue" ; exit 1}
$cctk = 'C:\Program Files\Dell\EndpointConfigure\X86_64\cctk.exe'
if (!(Test-path $cctk)) {Write-output "Dell CCTK not found. Unable to continue" ; exit 1}

$securebootstatus = cmd /C $cctk --secureboot

if ($securebootstatus -eq 'SecureBoot=Enabled') {Write-output "Happy days, Secure Boot is enabled" ; exit}
    else {Write-output "Secure Boot is not enabled.. proceeding to remediation" ; exit 1}