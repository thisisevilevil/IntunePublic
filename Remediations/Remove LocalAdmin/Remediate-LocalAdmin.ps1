Start-Transcript C:\Logs\AddLocalAdmin_Developer.log -Force -Append
function getupnofdeviceowner {
    $path = "HKLM:\SYSTEM\ControlSet001\Control\CloudDomainJoin\JoinInfo\*"
    $global:ownerupn = Get-ItemPropertyValue -path $path -Name "UserEmail"

    #This one takes a bit longer to populate, but should be a viable fix for scenarios where foouser is enrolling user
    if ($ownerupn -like '*fooUser*') {$global:ownerupn = get-itempropertyvalue "REGISTRY::HKEY_USERS\*\Local Settings\Software\Microsoft\MSIPC\*\Identities" -Name Email}

    #Return error code 1 if nothing is set in ownerupn
    if (!($ownerupn)) {Write-output "Unable to determine UPN from registry. Unable to continue" ; exit 1}
    
    Write-output "UPN of device owner should be $ownerupn"
    }

getupnofdeviceowner
Write-output "Removing user $ownerupn from local administrators group"
    
Try {
    Remove-LocalGroupMember -SID 'S-1-5-32-544' -Member "AzureAD\$ownerupn"
    }
    Catch {Write-output "An error occurred while trying to add $ownerupn to the Local administrators group. Error found: $_"}
    
Stop-Transcript