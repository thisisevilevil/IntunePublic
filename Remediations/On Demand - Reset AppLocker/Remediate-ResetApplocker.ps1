#Define general variables
$applockerkeys = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SrpV2\Exe'
$applockerfolder = "C:\Windows\System32\AppLocker\"
$grouppolicyfolder = "C:\Windows\System32\GroupPolicy"
$currentdate = get-Date -Format 'ddMMyyyy_hhMMss'

#Switch paths to SYSNATIVE if running in x86
if ($env:PROCESSOR_ARCHITECTURE -eq 'x86') {
$applockerfolder = "C:\Windows\Sysnative\AppLocker"
$grouppolicyfolder = "C:\Windows\Sysnative\GroupPolicy"
}

#Start transcript for debugging purposes
Start-Transcript "C:\Logs\ResetApplockerPolicies_$currentdate.log" -Force -Append

#Write bit level to host
Write-host "Starting AppLocker cleanup script"
Write-host "We are running in $env:PROCESSOR_ARCHITECTURE mode"

#Delete all local group policies
Remove-Item "$grouppolicyfolder" -Force -Recurse

#Locate all applocer files + reg keys
$applockerpolicies = gci $applockerkeys
$applockerfiles = gci $applockerfolder

#Remove all AppLocker exe REG Keys
Remove-Item $applockerkeys -recurse -Verbose

#Remove all AppLocker files stores under C:\Windows\System32\Applocker
ForEach ($file in $applockerfiles) {
$target = $file.FullName
Remove-item $target -Verbose -Force
}

#Schedule a reboot, gpupdate and stop transcription
shutdown -r -t 900 -c "We have reset the policies on this device, it will reboot automatically in 15 minutes."
Stop-Transcript
gpupdate 