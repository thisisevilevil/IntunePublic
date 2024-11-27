$regpath = 'HKCU:\Control Panel\Keyboard'
$regname = 'PrintScreenKeyForSnippingEnabled'

$targetsetting = Get-ItemPropertyValue -Path $regpath -Name $regname

if (!($targetsetting -eq '0')) {
Write-output "Built-in print screen functionality is not disabled.. proceeding to remediation"
exit 1
}