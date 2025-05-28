#Deploys a local admin user using a password "encrypted" in base64 - Should not be used if you can avoid it, as password can easily be decrypted. Can be used for easy ad-hoc troubleshooting when required

$encryptedstring = 'QnViYmVyc19iYWRla2Fy'
$pw = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($encryptedstring))
$adminpw = ConvertTo-SecureString -String $pw -AsPlainText -Force
$username = 'Bubber'

$users = (gwmi -class Win32_UserAccount -Filter "LocalAccount=True").Name
if ($users -contains $username) {
    Write-Host "User already created. Setting password again for existing user"
    Set-LocalUser -Name $username -Password $encryptedstring
    exit
}

New-LocalUser -Name $userName -Password $adminpw -PasswordNeverExpires:$true -AccountNeverExpires:$true -UserMayNotChangePassword:$true -ErrorAction Stop
Add-LocalGroupMember -SID 'S-1-5-32-544' -Member $username