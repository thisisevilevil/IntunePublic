$EPMKey = "HKLM:\SOFTWARE\Microsoft\EPMAgent"
$EPMVersion = Get-ItemPropertyValue -Path $EPMKey -Name 'ProductVersion'
$targetkey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EPM Agent"
$installdate = Get-Date -Format 'yyyyddMM'

if (!(Test-Path $targetkey)) {New-Item $targetkey}
New-ItemProperty -Path $targetkey -Name 'DisplayName' -Value 'Microsoft EPM Agent' -Force -PropertyType 'String'
New-ItemProperty -Path $targetkey -Name 'DisplayVersion' -Value $EPMVersion -Force -PropertyType 'String'
New-ItemProperty -Path $targetkey -Name 'Publisher' -Value 'Microsoft' -Force -PropertyType 'String'
New-ItemProperty -Path $targetkey -Name 'DisplayIcon' -Value 'C:\Program Files\Microsoft EPM Agent\EPMShellExtension\EndpointPrivilegeManagement.ico' -Force -PropertyType 'String'
New-ItemProperty -Path $targetkey -Name 'InstallDate' -Value $installdate -Force -PropertyType 'String'
