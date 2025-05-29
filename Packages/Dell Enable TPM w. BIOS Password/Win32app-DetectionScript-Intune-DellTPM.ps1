#Dell Specific TPM Check
$cctk = 'C:\Program Files\Dell\EndpointConfigure\X86_64\cctk.exe'
$tpmcheck = cmd /C $cctk --Tpm
if ($tpmcheck -eq 'TpmSecurity=Enabled') {Write-host "TPM is Enabled"}

#Alternative TPM Check
$tpmstatus = (Get-TPM).TpmPresent
if ($tpmstatus) {Write-host "TPM is enabled"}