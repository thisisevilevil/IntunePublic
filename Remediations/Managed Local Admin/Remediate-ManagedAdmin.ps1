function getadministratorsgroupname {
    #Function to get the members of the local administrators group. 
    #Needed as long we have devices that is not running en-us version of windows and Microsoft not fixing the bug with Get-LocalGroupMember powershell commandlet (https://github.com/PowerShell/PowerShell/issues/2996)
    $AdminGroupSid = 'S-1-5-32-544'
    $AdminGroup = New-Object System.Security.Principal.SecurityIdentifier($AdminGroupSid)
    $global:administrators = $AdminGroup.Translate([System.Security.Principal.NTAccount]).Value -replace '.+\\'
    Write-output "Administrators group should be named $administrators"
    }

$encryptedstring = 'Z3I4X2I4X204X3JhdGVfOG91dG9mOA=='
$pw = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($encryptedstring))
$adminpw = ConvertTo-SecureString -String $pw -AsPlainText -Force
$username = 'Masterblaster'
getadministratorsgroupname
$localadmins = net localgroup $administrators

$users = (gwmi -class Win32_UserAccount -Filter "LocalAccount=True").Name
if ($users -contains $username) {
    Write-Host "User already created. Checking if user is member of local admin group" 
    if ($localadmins -like $username) {Write-output "$username is already detected in local admin group. No additional actions performed"}
        else {
            Write-output "$username not member of local administrators group with name of $administrators. Adding $username to local admins group"
            Add-LocalGroupMember -SID 'S-1-5-32-544' -Member $username
            exit
        }
    Write-output "All should be good. No actions performed"
}
    else {
        Write-output "Creating new $username account on device"
        New-LocalUser -Name $userName -Password $adminpw -PasswordNeverExpires:$true -AccountNeverExpires:$true -ErrorAction Stop
        Add-LocalGroupMember -SID 'S-1-5-32-544' -Member $username
    }
