
<#
This script will return the available disk space. If available disk space is below 20GB it will return an error to console and exit with error code 1

Mads Johansen / mcj@apento.com
#>

#Size in GB - When space drops below this amount, it will trigger a cleanup
$threshhold = '10'

function Convert-Size {            
    [cmdletbinding()]            
    param(            
        [validateset("Bytes","KB","MB","GB","TB")]            
        [string]$From,            
        [validateset("Bytes","KB","MB","GB","TB")]            
        [string]$To,            
        [Parameter(Mandatory=$true)]            
        [double]$Value,            
        [int]$Precision = 4            
    )            
    switch($From) {            
        "Bytes" {$value = $Value }            
        "KB" {$value = $Value * 1024 }            
        "MB" {$value = $Value * 1024 * 1024}            
        "GB" {$value = $Value * 1024 * 1024 * 1024}            
        "TB" {$value = $Value * 1024 * 1024 * 1024 * 1024}            
    }            
                
    switch ($To) {            
        "Bytes" {return $value}            
        "KB" {$Value = $Value/1KB}            
        "MB" {$Value = $Value/1MB}            
        "GB" {$Value = $Value/1GB}            
        "TB" {$Value = $Value/1TB}            
                
    }            
                
    return [Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)            
                
    }            

#Get available disk space on C
$Win32_LogicalDisk = Get-ciminstance Win32_LogicalDisk | where {$_.DeviceID -eq "C:"}
$freespacebytes = $Win32_LogicalDisk.Freespace
$freespace = Convert-Size -From Bytes -To GB -Value $freespacebytes

if ($freespace -lt $threshhold) {
    Write-output "Low Disk space detected. Available disk space is $freespace (GB). Returning error to console"
    exit 1
}