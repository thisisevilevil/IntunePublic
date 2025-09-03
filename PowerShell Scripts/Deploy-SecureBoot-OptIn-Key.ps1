#Deploys a registry key to enable Microsoft Update managed Secure Boot key opt-in
#reference: https://support.microsoft.com/en-us/topic/windows-devices-for-businesses-and-organizations-with-it-managed-updates-e2b43f9f-b424-42df-bc6a-8476db65ab2f
$Path  = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot'
$Name  = 'MicrosoftUpdateManagedOptIn'
$Value = 0x5944  # 22852 decimal

if (!(Test-Path $Path)) {New-Item -Path $Path -Force}
New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force