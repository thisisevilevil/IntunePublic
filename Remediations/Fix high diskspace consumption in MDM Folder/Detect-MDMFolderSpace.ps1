$FolderPath = "C:\Windows\System32\config\systemprofile\AppData\Local\mdm"
$ThresholdGB = 1

if (Test-Path $FolderPath) {
    $FolderSizeBytes = (Get-ChildItem -Path $FolderPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $FolderSizeGB = [math]::Round($FolderSizeBytes / 1GB, 2)
} else {
    Write-Output "Folder not found: $FolderPath - no actions performed"
    exit
}

if ($FolderSizeGB -gt $ThresholdGB) {
    Write-Output "Folder size $FolderSizeGB GB exceeds threshold of $ThresholdGB GB."
    exit 1  # Non-zero exit code triggers remediation
} else {
    Write-Output "Folder size $FolderSizeGB GB is within limits. - no actions performed"
    exit
}
