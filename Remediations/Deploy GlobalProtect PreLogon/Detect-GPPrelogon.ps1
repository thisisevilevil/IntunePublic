$path = 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\Settings'
$name = 'PreLogon'

$prelogon = Get-ItemPropertyValue -Path -Name $name

if (!($prelogon -eq '1')) {
Write-output "Prelogon not enabled in registry.. proceeding to remediation"
exit 1
}