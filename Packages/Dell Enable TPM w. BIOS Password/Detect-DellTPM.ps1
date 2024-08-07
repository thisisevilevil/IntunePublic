$cctk = 'C:\Program Files\Dell\EndpointConfigure\X86_64\cctk.exe'
if (!(Test-path $cctk)) {Write-output "Dell CCTK is missing. Please install Dell Command | Configure to continue" ; exit 1}

$tpmcheck = cmd /C $cctk --Tpm
if ($tpmcheck -eq 'TpmSecurity=Enabled') {Write-host "TPM is Enabled"}