# Intel(R) RPC library utility
# Author: Grant Kelly, grant.l.kelly@intel.com
#
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see https://www.gnu.org/licenses/
#
#
#Requires -Version 5 -RunAsAdministrator
param (
    [Parameter(Mandatory = $false, Position=0)]
    [string]$action,
    [Parameter(Mandatory = $false, Position=1)]
    [string]$amtpassword,
    [Parameter(Mandatory = $false, Position=2)]
    [string]$certBase64,
    [Parameter(Mandatory = $false, Position=3)]
    [string]$certpassword
)

Function Invoke-RpcCommand {
    Write-Host -ForegroundColor CYAN "Checking RPC access to AMT..."
    $returnCode = [ClientAgent]::rpcCheckAccess()
    If ($returnCode -eq 0) {
        Write-Host -ForegroundColor GREEN "Access check completed successfully: return code[$returnCode]`n"
        $commandBytes = [System.Text.Encoding]::ASCII.GetBytes($cmd)
        $output = [IntPtr]::Zero
        Write-Host -ForegroundColor CYAN "CALLING RPC with action: $cmd"
        $returnCode = [ClientAgent]::rpcExec($commandBytes, [ref]$output)
        $outputString = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($output)
        If ($returnCode -eq 0) {
            Write-Host -ForegroundColor GREEN "Command completed successfully: return code[$returnCode]`n$outputString"
        } Else {
            Write-Host -ForegroundColor RED "Command failed with return code: $returnCode and error:`n$outputString"
        }
    } Else {
        Write-Host -ForegroundColor RED "Access check failed with return code: $returnCode"
    }
}

# Main execution function - called at end of script after large Base64 string
# Called as a function for easier readability
#
Function MainExecution {
# Define the inline C# code to interact with the DLL
$source = @"
    using System;
    using System.Runtime.InteropServices;

    public class ClientAgent
    {
        [DllImport("C:\\Program Files\\Intel Corporation\\vProFleetServicesAgent\\Modules\\c2c\\rpc.dll")]
        public static extern int rpcCheckAccess();

        [DllImport("C:\\Program Files\\Intel Corporation\\vProFleetServicesAgent\\Modules\\c2c\\rpc.dll")]
        public static extern int rpcExec(byte[] rpccmd, ref IntPtr output);
    }
"@

    Add-Type -TypeDefinition $source -Language CSharp
    If ([String]::IsNullOrEmpty($action)) {
        Write-Host -ForegroundColor DARKYELLOW "Atleast one supported action must be provided!`n`nActions:`n     amtinfo"
        $script:cmd = 'amtinfo'
    } ElseIf ($action -eq 'deactivate') {
        $script:cmd = "$action -local -password $amtpassword"
    } Else {
        $script:cmd = "$action"
    }
    Invoke-RpcCommand
}

MainExecution
 