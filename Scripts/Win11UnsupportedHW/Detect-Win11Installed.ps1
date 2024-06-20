$osversion = (gcim win32_operatingsystem).Version
if ($osversion -like '*10.0.22*') {Write-host "Windows 11 is installed"}