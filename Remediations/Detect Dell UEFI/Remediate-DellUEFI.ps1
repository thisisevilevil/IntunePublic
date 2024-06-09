if (!(($(gwmi win32_bios).Manufacturer -like '*Dell*'))) {Write-output "This is not a dell Device. unable to continue" ; exit 1}

if ($(Get-Disk).PartitionStyle -eq 'GPT') {
$cctk = 'C:\Program Files (x86)\Dell\Command Configure\X86_64\cctk.exe'
    if (!(Test-path $cctk)) {Write-output "Dell CCTK cannot be found.. unable to continue" ; exit 1}
$securebootenable = cmd /C $cctk --secureboot=enable
Start-Sleep -Seconds 5
exit

#Export result to simple log file
$securebootenable | out-file C:\Logs\Remediate-SecureBoot.log
}
    else {Write-output "PartitionStyle is not GPT. We don't support this yet"}