#This script can be used on hybrid-joined devices that has been inadvertently been deleted from Intune, where a re-enollment is required

$RegistryKeys = "HKLM:\SOFTWARE\Microsoft\Enrollments", "HKLM:\SOFTWARE\Microsoft\Enrollments\Status","HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked", "HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled", "HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers","HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts", "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger", "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions"

$EnrollmentID = Get-ScheduledTask -taskname 'PushLaunch' -ErrorAction SilentlyContinue | Where-Object {$_.TaskPath -like "*Microsoft*Windows*EnterpriseMgmt*"} | Select-Object -ExpandProperty TaskPath -Unique | Where-Object {$_ -like "*-*-*"} | Split-Path -Leaf

		foreach ($Key in $RegistryKeys) {
				if (Test-Path -Path $Key) {
					get-ChildItem -Path $Key | Where-Object {$_.Name -match $EnrollmentID} | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
	}
}
$IntuneCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {
		$_.Issuer -match "Intune MDM" 
	} | Remove-Item
if ($EnrollmentID -ne $null) { 
	foreach ($enrollment in $enrollmentid){
			Get-ScheduledTask | Where-Object {$_.Taskpath -match $Enrollment} | Unregister-ScheduledTask -Confirm:$false
			$scheduleObject = New-Object -ComObject schedule.service
			$scheduleObject.connect()
			$rootFolder = $scheduleObject.GetFolder("\Microsoft\Windows\EnterpriseMgmt")
			$rootFolder.DeleteFolder($Enrollment,$null)
} 
} 

$EnrollmentIDMDM = Get-ScheduledTask | Where-Object {$_.TaskPath -like "*Microsoft*Windows*EnterpriseMgmt*"} | Select-Object -ExpandProperty TaskPath -Unique | Where-Object {$_ -like "*-*-*"} | Split-Path -Leaf
		foreach ($Key in $RegistryKeys) {
				if (Test-Path -Path $Key) {
					get-ChildItem -Path $Key | Where-Object {$_.Name -match $EnrollmentIDMDM} | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
	}
}
if ($EnrollmentIDMDM -ne $null) { 
	foreach ($enrollment in $enrollmentidMDM){
			Get-ScheduledTask | Where-Object {$_.Taskpath -match $Enrollment} | Unregister-ScheduledTask -Confirm:$false
			$scheduleObject = New-Object -ComObject schedule.service
			$scheduleObject.connect()
			$rootFolder = $scheduleObject.GetFolder("\Microsoft\Windows\EnterpriseMgmt")
			$rootFolder.DeleteFolder($Enrollment,$null)
} 
$IntuneCert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {
		$_.Issuer -match "Microsoft Device Management Device CA" 
	} | Remove-Item
}	
Start-Sleep -Seconds 5
$EnrollmentProcess = Start-Process -FilePath "C:\Windows\System32\DeviceEnroller.exe" -ArgumentList "/C /AutoenrollMDM" -NoNewWindow -Wait -PassThru