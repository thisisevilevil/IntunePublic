<#
.SYNOPSIS
    Remediation script for AutoAcceptSsoPermission registry value.
.DESCRIPTION
    Creates HKLM\SOFTWARE\Policies\Microsoft\Windows\AAD\AutoAcceptSsoPermission (DWORD)
    and sets it to 1. Creates the key path if it does not exist.
#>

$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AAD"
$ValueName = "AutoAcceptSsoPermission"
$DesiredValue = 1
$LogFile = "C:\Windows\Logs\Remediate-AutoAcceptSsoPermission.log"

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$Timestamp - $Message" -ErrorAction SilentlyContinue
}

try {
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
        Write-Log "Created registry key: $RegPath"
    }

    New-ItemProperty -Path $RegPath -Name $ValueName -Value $DesiredValue -PropertyType DWord -Force | Out-Null
    Write-Log "Set $ValueName to $DesiredValue"

    Write-Output "Remediation successful: $ValueName set to $DesiredValue"
    exit 0
}
catch {
    Write-Log "Remediation failed: $($_.Exception.Message)"
    Write-Output "Remediation failed: $($_.Exception.Message)"
    exit 1
}
