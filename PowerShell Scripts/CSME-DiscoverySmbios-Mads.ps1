<#

This snippet demonstrates how to read SMBIOS via WMI to determine whether the local endpoint 
executing the script has Intel(R) AMT or Intel(R) Standard Manageability, and what version of 
Intel(R) Manageability Engine firmware is available.  

It is recommended to run this script as an administrator.

###################################################################################################

Copyright 2024 Intel Corporation.

This software and the related documents are Intel copyrighted materials, and your use of them is 
governed by the express license under which they were provided to you ("License"). Unless the 
License provides otherwise, you may not use, modify, copy, publish, distribute, disclose or 
transmit this software or the related documents without Intel's prior written permission.

This software and the related documents are provided as is, with no express or implied warranties, 
other than those that are expressly stated in the License.

###################################################################################################

Adjusted this script slightly to add support for Win32 app requirements //Mads Johansen

Source: https://www.intel.com/content/www/us/en/download/19693/intel-endpoint-management-assistant-intel-ema-api-sample-scripts.html

#>

#Requires -Version 5

# Read SMBIOS data via WMI ########################################################################

$smbiosBytes = (Get-WmiObject -Namespace root\WMI -Class MS_SmBios).SMBiosData
$smbiosHex = ([System.BitConverter]::ToString($smbiosBytes))

# Find $AMT signature as anchor to to locate Intel(R) ME attributes ###############################

If ($smbiosHex.Contains('24-41-4D-54')) {    
    [int]$signatureLoc = ($smbiosHex.IndexOf('24-41-4D-54'))
    [int]$tableLength = ([convert]::ToInt16($smbiosHex.Substring($signatureLoc - 9).Substring(0,2), 16))

    # Calculate offsets to locate Intel(R) ME attributes in SMBIOS data ###########################

    # Note that offsets are different with 12th gen CPUs
    If ($tableLength -eq '20') {
        [int]$offset = 173
    } Else {
        [int]$baseOff = (($tableLength - 20) * 3)
        [int]$offset = 173 + $baseOff
    }

    # Identify Intel(R) ME SKU ####################################################################
    
    $skuHex = $smbiosHex.Substring($signatureLoc - 12,$offset).Substring($offset - 35,5)
    $skuInt = [convert]::ToUInt16($skuHex.Substring(3,2) + $skuHex.Substring(0,2), 16)
    If ($skuInt -band 8) {
        $skuStr = "Intel(R) Full AMT Manageability"
    } ElseIf ($skuInt -band 16) {
        $skuStr = "Intel(R) Standard Manageability"
    } ElseIf ($skuInt -band 32) {
        $skuStr = "Intel(R) Small Business Advantage(SBA)"
    } Else {
        $skuStr = "Consumer"
    }
    
    # Identify Intel(R) ME version ################################################################

    $version = $smbiosHex.Substring($signatureLoc - 12,$offset).Substring($offset - 23,23)    
        
    # ME FW version in hex is in min, maj, rev, hf order, but should be written as maj.min.hf.rev
    $minVer = [convert]::ToInt16($version.Substring(3,2) + $version.Substring(0,2), 16)
    $majVer = [convert]::ToInt16($version.Substring(9,2) + $version.Substring(6,2), 16)
    $revVer = [convert]::ToInt16($version.Substring(15,2) + $version.Substring(12,2), 16)
    $hfVer = [convert]::ToInt16($version.Substring(21,2) + $version.Substring(18,2), 16)    

    # Identify Intel(R) ME enabled state ##########################################################

    $meEnabled = $false
    If (($smbiosHex.Substring($signatureLoc + 12).Substring(0,2) -eq '01') -and ($smbiosHex.Substring($signatureLoc + 12).Substring(3,2) -eq '01')) {
        $meEnabled = $true
    } 
    
    # Identify non-Intel(R) vPro Platforms ########################################################

    # Note that Intel(R) vPro Essentials systems are Intel(R) Standard Manageability systems with Intel AMT version 16 and up.
    If ($skuInt -band 16) { # Intel(R) Standard Manageability
        If ($majVer -lt 16) {
            Write-Host -ForegroundColor Yellow "Intel(R) vPro platform".PadRight(40,'.')"`b: $false"
            Write-Host -ForegroundColor Yellow "Intel(R) ME SKU".PadRight(40,'.')"`b: $skuStr"            
            exit 1
        }
    } ElseIf (!($skuInt -band 8)) { # not Intel(R) Full AMT Manageability
        Write-Host -ForegroundColor Yellow "Intel(R) vPro platform".PadRight(40,'.')"`b: $false"
        Write-Host -ForegroundColor Yellow "Intel(R) ME SKU".PadRight(40,'.')"`b: $skuStr"
        exit 1
    }

    # Report results ############################################################################## 

    Write-Host -ForegroundColor Green "Intel(R) vPro platform".PadRight(40,'.')"`b: $true"
    Write-Host -ForegroundColor Green "Intel(R) ME version".PadRight(40,'.')"`b: $majVer.$minVer.$hfVer.$revVer"
    Write-Host -ForegroundColor Green "Intel(R) ME enabled".PadRight(40,'.')"`b: $meEnabled"
    Write-Host -ForegroundColor Green "Intel(R) ME SKU".PadRight(40,'.')"`b: $skuStr"
    
    #Write-output 1 to Intune for Win32 app management
    Write-output "1"

} Else { # $AMT signature not found in SMBIOS data
    
    # Report results when $AMT signature not found ################################################

    Write-Host -ForegroundColor Red "Intel(R) vPro platform".PadRight(40,'.')"`b: $false"
    Return

}
