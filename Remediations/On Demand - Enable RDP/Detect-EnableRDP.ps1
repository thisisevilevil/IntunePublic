$tsconnections = Get-ItemPropertyValue -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections"
if (!($tsconnections -eq '0')) {Write-output "RDP Not enabled on this device, proceeding to remediation" ; exit 1}
    else {Write-output "RDP already enabled. No actions performed"}


$rdpusers = net localgroup "Remote Desktop Users"
if (!($rdpusers -like '*everyone*')) {Write-host "everyone is not part of the RDP Group.. found following members: $rdpusers - proceeding to remediation" ; exit 1}