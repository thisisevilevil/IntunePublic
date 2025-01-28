$osversion = (gcim win32_operatingsystem).Version
if ($osversion -like '*10.0.2*') {Write-host "Windows 11 is installed"}