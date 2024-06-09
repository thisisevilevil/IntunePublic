function getremotedesktopusersgroupname {
    #Function to get the members of the local administrators group. 
    #Needed as long we have devices that is not running en-us version of windows and Microsoft not fixing the bug with Get-LocalGroupMember powershell commandlet (https://github.com/PowerShell/PowerShell/issues/2996)
    $RemoteUsersSID = 'S-1-5-32-555'
    $RemoteGroup = New-Object System.Security.Principal.SecurityIdentifier($RemoteUsersSID)
    $global:remotedesktopusers = $RemoteGroup.Translate([System.Security.Principal.NTAccount]).Value -replace '.+\\'
    Write-output "Remote Desktop users group should be named $RemoteDesktopUsers"
    }

getremotedesktopusersgroupname
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Add-LocalGroupMember -Group $remotedesktopusers -Member "S-1-1-0"

#Derpy workaround for systems not using en-US Windows
Get-NetFirewallRule | Where-Object {$_.Description -like '*3389*'} | Enable-NetFirewallRule