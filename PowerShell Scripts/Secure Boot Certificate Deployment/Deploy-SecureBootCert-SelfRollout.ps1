#Deploys a registry key to enable Microsoft Update managed Secure Boot key opt-in
#reference: https://evil365.com/intune/SecureBoot-Cert-Expiration/#option-2---automatic-rollout-via-microsoft-controlled-feature-rollout-cfr
#reference: https://support.microsoft.com/en-us/topic/registry-key-updates-for-secure-boot-windows-devices-with-it-managed-updates-a7be69c9-4634-42e1-9ca1-df06f43f360d#bkmk_registry_keys

$Path  = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\'
$Name  = 'AvailableUpdates'
$Value = 0x5944

if (!(Test-Path $Path)) {New-Item -Path $Path -Force}
New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force