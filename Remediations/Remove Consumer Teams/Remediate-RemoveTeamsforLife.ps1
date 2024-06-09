If ($null -eq (Get-AppxPackage -Name MicrosoftTeams -AllUsers)) {
    Write-Output "Microsoft Teams Personal App not present"
}
Else {
    Try {
        Write-Output "Removing Microsoft Teams Personal App"
        If (Get-Process msteams -ErrorAction SilentlyContinue) {
            Try {
                Write-Output "Stopping Microsoft Teams Personal app process"
                Stop-Process -Processname msteams -Force
                Write-Output "Stopped"
            }
            catch {
                Write-Output "Unable to stop process, trying to remove anyway"
            }
           
        }
        Get-AppxPackage -Name MicrosoftTeams -AllUsers | Remove-AppPackage -AllUsers
        Write-Output "Microsoft Teams Personal App removed successfully"
    }
    catch {
        Write-Error "Error removing Microsoft Teams Personal App"
    }
}