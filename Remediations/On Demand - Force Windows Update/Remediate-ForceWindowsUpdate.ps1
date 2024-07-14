#Set PSGallery as Trusted repository
Set-PSRepository -InstallationPolicy Trusted -Name PSGallery -Verbose

#Install required modules
Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force -Verbose
Import-Module PSWindowsUpdate

#Install all updates from Windows Update
Get-WindowsUpdate -WindowsUpdate -AcceptAll -Install -Silent -Verbose

#Collect the WindowsUpdateLog file.
Get-WindowsUpdateLog -LogPath C:\Windows\Logs\Intune-OnDemand-WindowsUpdate.log