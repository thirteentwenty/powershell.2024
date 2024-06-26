<#
.Synopsis
    This script will gracefully close a single application then restart the computer
.DESCRIPTION
	
.EXAMPLE
    .\closeAndReboot-v0.02.ps1 [interval in seconds]
    Example :: 
    .\closeAndReboot-v0.02.ps1 7200 (120 Minutes)
.NOTES
    - Variables
    $appName - Change this variable to the application you would like to close
               before the computer reboots
    
.NOTES
    Author: Keola McColgan
    Date Created: 2024.03.02
    Versoin 0.05
    (2024.03.29)
    Added fucntion to remove screenshots

    Version 0.04
    (2024.03.13)
    removed the Graceful shutdown sections in the if/else and
    replaced them with a single function

    Updated the if statement looking for the time parameter when
    calling the script placing $null on the left side.

    Version 0.03
    (2024.03.09)
    Added graceful shutdown of vBox guest OS's

    Version 0.02
    (2024.03.05)
    Finished the script header
    Created variables for the the application name for ease of use
    
    Version 0.01 
    A proof of concept test but ultimately recodded because
    I didn't like the timing mechnism.
#>

$executionIntervalSeconds = $args[0]
$timeStart = Get-Date -Format "HH:mm.ss yyyy.MM.dd"
$appName = "firefox"
$appToClose = Get-Process $appName -ErrorAction SilentlyContinue

function shutdownGuestOS {
    # Graceful shutdown of vBox guest OS's
    $vBoxManage = "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe"
    $listRunningGuests = & $vBoxManage list runningvms

    foreach ($runningGuest in $($listRunningGuests)){
        $runningGuest = $($runningGuest).split('"')[1]
        & $vBoxManage controlvm $($runningGuest) acpipowerbutton
    }
}

function removeScreenhots {
    $screenShotDir = ([System.Environment]::GetFolderPath("MyPictures") + "\Screenshots")
    Get-ChildItem $($screenShotDir) | Remove-Item
}

if ($null -eq $($executionIntervalSeconds)) {
    $executionIntervalSeconds = Read-Host Please enter the delay in seconds
}

$executionIntervalMinutes = ($($executionIntervalSeconds) / 60)

if ($appToClose) {
    Write-Host "The computer will shut down in $($executionIntervalMinutes) Minutes..."
    Write-Host $timeStart

    shutdownGuestOS
    removeScreenhots

    # Sleep for specified interval 
    Start-Sleep -Seconds $($executionIntervalSeconds)
    
    (Get-Process -Name $($appName)).CloseMainWindow() | Out-Null
    Write-Host $appName Closed

    Restart-Computer -Force
} else {
    
    Write-Host "The computer will shut down in $($executionIntervalMinutes) Minutes..."
    Write-Host $timeStart

    shutdownGuestOS
    removeScreenhots

    # Sleep for specified interval 
    Start-Sleep -Seconds $($executionIntervalSeconds)
    Restart-computer -Force
}
