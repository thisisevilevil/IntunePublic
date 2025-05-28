$keytxturl = '<InsertUrltoTxt>'
$keyfileurl = '<InsertUrltoKey>'
$keytxt = "$env:systemroot\Temp\tmpk.txt"
$keyfile = "$env:systemroot\Temp\tmpk.key"
$localadmins = Invoke-Command {net localgroup administrators}
$username = '<InsertUserName>'
$description = "This account is a managed local admin account"

if ($localadmins -like "*$username*") {Write-host "We already added our local admins. Exiting without performing changes"
exit}

if (!(Test-Path $keytxt)) {Invoke-Webrequest $keytxturl -OutFile "$keytxt"}
if (!(Test-Path $keyfile)) {Invoke-Webrequest $keyfileurl -OutFile "$keyfile"}

#Decrypt key files and create secure string object
$pw = ((Get-Content $keytxt) | ConvertTo-SecureString -Key (Get-Content $KeyFile))        

#Local Admins - In case the client looses connection to AzureAD
$creds = New-Object System.Management.Automation.PSCredential("Nope",$pw)
New-LocalUser -Name $username -password $creds.password -PasswordNeverExpires -AccountNeverExpires -Description $description -UserMayNotChangePassword | Set-LocalUser -PasswordNeverExpires $True -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group 'Administrators' -Member $username -ErrorAction SilentlyContinue

#Remove temp keys
Remove-Item $keytxt -ErrorAction SilentlyContinue
Remove-Item $keyfile -ErrorAction SilentlyContinue

#exit
exit


