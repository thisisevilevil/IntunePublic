if (!(($(gwmi win32_bios).Manufacturer -like '*Dell*'))) {Write-output "This is not a dell Device. unable to continue" ; exit}
Write-output "Starting one-time update of Dell device using Dell Command | Update"
exit 1