$updatenotifications = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule' -name "DisableNotification"
if (!($updatenotifications -eq '1')) {Write-output "Dell Update Notifications is not disabled on this device.. proceeding to remediation" ; exit 1}
    else {Write-output "Dell Update Notifications already turned off on this device"}