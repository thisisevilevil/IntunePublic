$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$name = "HiberbootEnabled"

$value = Get-ItemPropertyValue -Path $path -Name $name

if (!($value -eq '0')) {
Write-output "Fast Startup is not disabled.. proceeding to remediation"
exit 1
}