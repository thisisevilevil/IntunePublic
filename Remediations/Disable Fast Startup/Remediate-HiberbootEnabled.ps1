$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$name = "HiberbootEnabled"

if (!(Test-Path $path)) {New-Item $path -Force}
New-ItemProperty -Path $path -Name $name -PropertyType DWORD -Value '0' -Force