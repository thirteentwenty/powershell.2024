<#
.Synopsis
    
.DESCRIPTION
	
.EXAMPLE
	.\closeAndReboot-v0.02.ps1 [interval in seconds]

    .\closeAndReboot-v0.02.ps1 7200 (120 Minutes)
.NOTES
	
.NOTES
    Author: Keola McColgan
    Modified date: 2024.03.02
    Version 0.02
#>

$executionIntervalSeconds = $args[0]
$timeStart = Get-Date -Format "HH:mm.ss yyyy.MM.dd"
$firefox = Get-Process firefox -ErrorAction SilentlyContinue

if ($($executionIntervalSeconds) -eq $null) {
    $executionIntervalSeconds = Read-Host Please enter the delay in seconds
}

$executionIntervalMinutes = ($($executionIntervalSeconds) / 60)

if ($firefox) {
    Write-Output "The computer will shut down in $($executionIntervalMinutes) Minutes..."
    Write-Output $timeStart
    # Sleep for specified interval 
    Start-Sleep -Seconds $($executionIntervalSeconds)
    
    (Get-Process -Name firefox).CloseMainWindow() | Out-Null
    Write-Host Firefox Closed

    Restart-Computer -Force
}
