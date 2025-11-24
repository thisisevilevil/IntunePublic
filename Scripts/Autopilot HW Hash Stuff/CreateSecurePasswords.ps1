<#
 #This script will create an encrypted password files for your passwords
 #Use the "encryptpassword" function to encrypt your password. This will generate 2 files for you. How you store the files is up to you, just keep them in a safe place, and lock down the share/NTFS Rights
 #Use the "decryptpassword" function to decrypt your password files you in your script
#>


function encryptpassword {
#Define variables
$Directory = "C:\temp"
$KeyFile = "$Directory\master.key"
$PasswordFile = "$Directory\master.txt"
 
$Password = Read-Host -Prompt 'Input secure password' -AsSecureString
 
#Create AES-256bit key file
try {
 $Key = New-Object Byte[] 32
 [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
 $Key | out-file $KeyFile
        $KeyFileCreated = $True
 Write-Host "The key file $KeyFile was created successfully"
} catch {
 write-Host "An error occurred trying to create the key file $KeyFile (error: $($Error[0])"
}
 
Start-Sleep 1
 
#Add the plaintext password to the password file (and encrypt it based on the AES key file)
If ($KeyFileCreated -eq $True) {
 try {
 $Key = Get-Content $KeyFile
 $Password | ConvertFrom-SecureString -key $Key | Out-File $PasswordFile
 Write-Host "The key file $PasswordFile was created successfully"
 } catch {
 write-Host "An error occurred trying to create the password file $PasswordFile (error: $($Error[0])"
 }
}
 
}


function decryptkey {
#Define variables
$Directory = "$home\Desktop"
$KeyFile = "$Directory\master.key"
$PasswordFile = "$Directory\master.txt"
 
### Read the secure password from a password file and decrypt it to a normal readable string
$SecurePassword = ((Get-Content $PasswordFile) | ConvertTo-SecureString -Key (Get-Content $KeyFile))
$SecurePasswordInMemory = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)             
$PasswordAsString = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($SecurePasswordInMemory)
[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($SecurePasswordInMemory);
}
