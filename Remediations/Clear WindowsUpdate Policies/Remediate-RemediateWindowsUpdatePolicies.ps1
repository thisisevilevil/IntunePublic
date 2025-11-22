Remove-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\*WindowsUpdate*" -Recurse
restart-service wuauserv