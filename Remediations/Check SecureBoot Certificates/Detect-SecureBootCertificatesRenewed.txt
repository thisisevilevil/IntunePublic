# Check if Secure Boot UEFI database contains 'Windows UEFI CA 2023'
$match = [System.Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI db).bytes) -match 'Windows UEFI CA 2023'

if ($match) {
    Write-output "Compliant: Windows UEFI CA 2023 found."
    exit
} else {
    Write-output "Non-Compliant: Windows UEFI CA 2023 not found."
    exit 1
}
