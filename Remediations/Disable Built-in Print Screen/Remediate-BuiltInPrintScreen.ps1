$regpath = 'HKCU:\Control Panel\Keyboard'
$regname = 'PrintScreenKeyForSnippingEnabled'

New-Item -Path $regpath -Name $regname -ItemType 'DWORD' -Value '0' -Force