$securebootstatus = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
$model = (gwmi win32_computersystem).model
$serialnumber = (gwmi win32_bios).SerialNumber
$manufacturer = (gwmi win32_bios).Manufacturer
if (!($securebootstatus -eq $true)) {Write-output "Secure boot is turned off. SystemInfo: $model,$serialnumber,$manufacturer" ; exit 1}
    else {Write-output "Secure Boot is turned on"}