$productkey = (gwmi SoftwareLicensingService).OA3xOriginalProductKey
if (!($productkey)) {Write-output "No product key found in BIOS. Motherboard replacement likely needed. unable to continue" ; exit 1}
    else {
    Write-output "Attempting to reapply product key from BIOS"
    exit 1
    }