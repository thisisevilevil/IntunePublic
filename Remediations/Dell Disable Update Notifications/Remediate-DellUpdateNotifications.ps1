$key = 'HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule'
if (!(Test-Path $key)) {New-Item $key -Force}
New-ItemProperty -Path $key -name "DisableNotification" -value 1 -PropertyType 'Dword'