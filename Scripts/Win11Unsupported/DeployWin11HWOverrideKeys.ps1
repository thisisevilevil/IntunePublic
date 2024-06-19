#Source: https://support.microsoft.com/en-us/windows/ways-to-install-windows-11-e0edbbfb-cfc5-4011-868b-2ce77ac7c70e
$path = 'HKLM:\SYSTEM\Setup\MoSetup'
$key = 'AllowUpgradesWithUnsupportedTPMOrCPU'
if (!(Test-Path $Path)) {New-Item $path -Force}
New-ItemProperty -Path $path -Name $key -Value '1' -PropertyType 'DWORD' -Force