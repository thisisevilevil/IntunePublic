# Check if current PowerShell session is running as Administrator
$IsElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if ($IsElevated) {
    Write-Host "PowerShell is running elevated (as Administrator), all is good." -ForegroundColor Green
} else {
    Write-Host "PowerShell is NOT running elevated - Please make sure to launch as administrator. Right click and press "Run as administrator" - This process will close in 5 seconds" -ForegroundColor Red
    Start-Sleep -Seconds 5
}

# Simple encryption method for storing the secret key.. should be avoided, can easily be decrypted. Use "secretstuff" where possible.
function secretstuffsimple {
    $global:bob = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String('<InsertB64String>'))   
}

# Encrypted key pair in blobstorage should go here. This is a more secure than the simple method above.
function secretstuff {
    $kfenc = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String('<InsertB64String>'))
    $pfenc = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String('<InsertB64String>'))
    $global:kf = "$env:temp\iuioufkhjxcvndiol.key"
    $global:pf = "$env:temp\yozxbchlzhfhaskkh.txt"

    if (!(Test-Path $kf)) {
        Try {Invoke-Webrequest -Uri $kfenc -OutFile $kf}
            Catch {throw}
        }
        
    if (!(Test-path $pf)) {
        Try {Invoke-Webrequest -Uri $pfenc -OutFile $pf}
            Catch {throw}
        }
        
    $global:henrik = ((Get-Content $pf | ConvertTo-SecureString -Key (Get-Content $kf)))
    $secpwinmem = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($henrik) 
    $global:jytte = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($secpwinmem)
    Remove-item -Path "$env:temp\iuioufkhjxcvndiol.key"
    Remove-item -Path "$env:temp\yozxbchlzhfhaskkh.txt"
}

# Install PackageManagement
Write-Output "Installing PackageManagement"
Install-Package -Name PackageManagement -Force -Confirm:$false -Source PSGallery

# Install PowershellGet
Write-Output "Installing PowershellGet"
Install-Package -Name PowershellGet -Force -Verbose

# Install all requires PowerShell modules
$psmodules = 'Microsoft.Graph.Beta.DeviceManagement.Enrollment','WindowsAutoPilotIntune'

ForEach ($psmodule in $psmodules) {
Write-Host "Installing module $psmodule" -NoNewline
Install-Module $psmodule -Force -ErrorAction Stop
Import-Module $psmodule -Force -PassThru -ErrorAction Ignore
}

cls

# Declare credentials for connecting to MS Graph + various variables
secretstuff # Remember to switch between secretstuffsimple and secretstuff depending on which method you want to use 

$manufacturer = (Get-WMIObject win32_bios).Manufacturer
$hwmodel = (Get-WMIObject win32_computersystem).Model
$tenantid = '<insert>' # <---- Replace with your tenant ID
$appid = '<insert>' # <---- Replace with your app registration client ID
$lars = ConvertTo-SecureString -String $bob -AsPlainText -Force
$henrik = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $appid, $lars


Connect-MgGraph -TenantId $tenantid -ClientSecretCredential $henrik -NoWelcome

cls

# Register device in autopilot and sleep for a bit to let autopilot things sync up
Write-host "Registering device in autopilot" -ForegroundColor Cyan
$hwid = ((Get-WMIObject -NameSpace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'").DeviceHardwareData)
$ser = (Get-WMIObject win32_bios).serialnumber
Add-AutopilotImportedDevice -serialnumber $ser -hardwareidentifier $hwid
Write-Host "This computer is in the process of being registered in autopilot. This can take up to 15 minutes. The computer will automatically reboot 15 minutes." -ForegroundColor Cyan
Write-Host "Do not reboot the device yourself" -ForegroundColor Red   
Write-host "`n`nInformation about device:`nSerialnumber: $ser`nManufacturer: $manufacturer`nModel: $hwmodel" -ForegroundColor Green


# You can remove below bit, if you are running this script unattended, or part of a task sequence.
Start-Sleep -Seconds 900
cls

Write-host "Finished! Syspreppring device to reset the autopilot process - Once the device restarted the device should be good to go" -ForegroundColor Green
Start-Sleep -Seconds 30
Start-Process 'C:\windows\system32\sysprep\sysprep.exe' -ArgumentList '/oobe /reboot'