$targetkey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

if (Test-Path $targetkey) {{Write-output "Windows Update Policies detected locally on the device - Proceeding to remediation" ; exit 1}
}

Write-output "No windows update policies detected. No actions performed"
exit