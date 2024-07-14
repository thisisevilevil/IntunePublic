<#
Windows Update Cleanup for Windows 7 + 10 Devices.
This script will cleanup common folders and reset the Windows Update component

Mads Johansen / mcj@apento.com

#>
$currentdate = Get-Date -format 'ddMMyyyy_HHmmss'
Start-Transcript C:\Windows\Logs\DiskCleanup_$currentdate.log

function resetwindowsupdate {
    $wsuspaths = @(
        "$env:WinDir\SoftwareDistribution\*"  
        "$env:WinDir\system32\catroot2\*" 
    )

    Write-Host "Reset Windows Update function called.. stopping all windows update services"

    #Stop windows update services
    Stop-Service "wuauserv" -Force -Verbose
    Stop-Service "CryptSvc" -force -Verbose
    Stop-Service "BITS" -force -Verbose

    ForEach ($path in $wsuspaths) {
    Remove-Item $path -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }

    #Sleep for 10 seconds
    Start-Sleep -Seconds 10

    #Cleanup finished - Restarting Windows Update Services
    Write-Host "Cleanup should be finished.. Starting necessary Windows Update Services once more"
    Start-Service "BITS" -Verbose
    Start-Service "CryptSvc" -Verbose
    Start-Service "wuauserv" -Verbose

}

Try {

    #Define some reg keys for CleanMgr
    Get-ChildItem -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' | New-ItemProperty -Name StateFlags001 -Value 2 -PropertyType DWORD
    
    Write-Host 'Starting CleanMgr.exe with /sagerun:1 and waiting up to 5 minutes for it to finish'
    Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle Hidden -Wait
    Get-Process -Name cleanmgr,dismhost -ErrorAction SilentlyContinue | Wait-Process -Timeout 300

    #Reset Windows Update Component on the device for good measure
    resetwindowsupdate

    #Find all users temp folders
    $usertemp = Get-ChildItem "C:\Users\*\AppData\Local\Temp"

    #Cleanup of common paths - Put more paths here if you want more paths to be cleaned up
    $targetpaths = @(
       "$env:ALLUSERSPROFILE\application data\Microsoft\Network\downloader\*"
       "$env:temp\*"
       "$env:WinDir\Temp\*"
       )


    #Cleanup all user temp folders present on the device
    ForEach ($path in $usertemp) {
        Remove-Item $path -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }
    
    #Cleanup of target paths
    ForEach ($path in $targetpaths) {
        Remove-Item $path -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }

}

Catch {
    $_.Exception.Message
    Stop-Transcript
}

Stop-Transcript