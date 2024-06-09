function getadministratorsgroupname {
#Function to get the members of the local administrators group. 
#Needed as long we have devices that is not running en-us version of windows and Microsoft not fixing the bug with Get-LocalGroupMember powershell commandlet (https://github.com/PowerShell/PowerShell/issues/2996)
$AdminGroupSid = 'S-1-5-32-544'
$AdminGroup = New-Object System.Security.Principal.SecurityIdentifier($AdminGroupSid)
$global:administrators = $AdminGroup.Translate([System.Security.Principal.NTAccount]).Value -replace '.+\\'
Write-output "Administrators group should be named $administrators"
}

$username = 'MasterBlaster'
$users = (gwmi -class Win32_UserAccount -Filter "LocalAccount=True").Name
getadministratorsgroupname
$localadmins = net localgroup $administrators

if ($users -contains $username) {
    Write-Host "User already created. Checking if it's added to local admin"
    if ($localadmins -like $username) {Write-output "$username is already detected in local admin group. No additional actions performed"}
        else {
            Write-output "$username not in local admin group.. proceeding to remediation. local admins output debug: $localadmins" ; exit 1
        }

}
    else {Write-output "$username user not created.. proceeding to remediation" ; exit 1}