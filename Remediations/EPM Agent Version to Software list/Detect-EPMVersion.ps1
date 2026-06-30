#This has been created to enable reporting on the EPM Agent version on our windows-based devices for debugging purposes.
#Context: Microsoft has during debugging sessions on EPM issues commonly asked us for the EPM Agent version. 
#Since it's not listed in add/remove programs and only under a custom reg key, this remediation will manually add an entry to the application list, allowing Intune app list and SNOW Inventory to pick up the EPM Agent version for easier reporting

$EPMKey = "HKLM:\SOFTWARE\Microsoft\EPMAgent"
$EPMVersion = Get-ItemPropertyValue -Path $EPMKey -Name 'ProductVersion'
$targetkey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EPM Agent"
$targetversion = Get-Itempropertyvalue -Path $targetkey -Name 'DisplayVersion'

if ($EPMVersion -ne $targetversion) {Write-output "EPM Agent version doesn't match Uninstall entry version, proceeding to remediation" ; exit 1}
    else {Write-output "No change detected, no actions performed"}
