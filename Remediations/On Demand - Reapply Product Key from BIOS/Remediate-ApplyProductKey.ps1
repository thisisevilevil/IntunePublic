$productkey = (gwmi SoftwareLicensingService).OA3xOriginalProductKey
if (!($productkey)) {Write-output "No product key found in BIOS. Motherboard replacement likely needed. unable to continue" ; exit 1}
    else {
        Write-output "Found productkey: $productkey"
        Write-output "Running following command now"
        iex "cscript /b C:\windows\system32\slmgr.vbs /ipk $productkey"
        iex "cscript /b C:\windows\system32\slmgr.vbs /ato"
        Start-Sleep -seconds 5

        #final check for activation status
        $activationstatus = Get-CimInstance SoftwareLicensingProduct -Filter "partialproductkey is not null" | ? name -like windows* | Select -ExpandProperty LicenseStatus
        $osname = Get-CimInstance SoftwareLicensingProduct -Filter "partialproductkey is not null" | ? name -like windows* | Select -ExpandProperty Name
            if (!($activationstatus -eq '1')) {Write-output "Unable to activate windows using product key $productkey"}
                else {Write-output "Windows is activated using $productkey - OS Version is $osname"}
    }