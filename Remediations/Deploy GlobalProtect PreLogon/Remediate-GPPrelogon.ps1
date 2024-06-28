$path = 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup'
$name = 'PreLogon'

if (!(Test-Path $path)) {New-Item $path -Force}
New-ItemProperty -Path $path -Name $name -PropertyType DWORD -Value '1'