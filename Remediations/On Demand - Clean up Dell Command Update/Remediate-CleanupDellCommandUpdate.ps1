$dcu = Get-WMIObject win32_product | Where {$_.Name -like '*Dell Command*'}
if ($dcu) {
    Write-host "DCU installed on this device.. we need to uninstall this first. Old version detected: $dcu.Version"
    $msiguid = $dcu.IdentifyingNumber
    Start-Process msiexec -Wait -ArgumentliSt "/X $msiguid /qn" -Verbose
    Start-Sleep -Seconds 5
}