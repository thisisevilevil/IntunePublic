$smb2protocol = Get-SmbServerConfiguration | Select -ExpandProperty EnableSMB2Protocol
if ($smb2protocol -eq 'True') {
    Write-Output "SMB 2/3 protocol is enabled. Proceeding to disable." ; exit 1
}