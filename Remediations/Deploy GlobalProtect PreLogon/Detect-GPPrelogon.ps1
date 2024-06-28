$path = 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup'
$name = 'PreLogon'

$prelogon = Get-ItemPropertyValue -Path $path -Name $name

if (!($prelogon -eq '1')) {
Write-output "Prelogon not enabled in registry.. proceeding to remediation"
exit 1
}