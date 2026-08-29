<#
.SYNOPSIS
    Detection script for AutoAcceptSsoPermission registry value.
.DESCRIPTION
    Exits 1 (non-compliant) if HKLM\SOFTWARE\Policies\Microsoft\Windows\AAD\AutoAcceptSsoPermission
    is missing or not set to 1. Exits 0 if compliant.
#>

$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AAD"
$ValueName = "AutoAcceptSsoPermission"
$ExpectedValue = 1

try {
    $CurrentValue = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop | Select-Object -ExpandProperty $ValueName

    if ($CurrentValue -eq $ExpectedValue) {
        Write-Output "Compliant: $ValueName is set to $ExpectedValue"
        exit 0
    }
    else {
        Write-Output "Non-compliant: $ValueName is set to $CurrentValue, expected $ExpectedValue"
        exit 1
    }
}
catch {
    Write-Output "Non-compliant: $ValueName not found or key missing"
    exit 1
}
