#Fix for TPM Maintenance task stuck - Fix on failure only, please only use where required

$path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OOBE'
New-ItemProperty -Path $path -Name 'SetupDisplayedEula' -PropertyType 'DWORD' -Value '1' -Force -Verbose
Start-Sleep -Seconds 20
Get-Scheduledtask *TPM-Maintenance* | Start-ScheduledTask -Verbose