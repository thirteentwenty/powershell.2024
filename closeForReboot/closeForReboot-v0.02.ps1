<#
.Synopsis
    This script will gracefully close an application and gracefully shutdown
    any VirtualBox guest OS's that are currently running.
.DESCRIPTION
	
.EXAMPLE
    No examples given, this script will run at logoff
    as a logoff script.
.NOTES
    - Variables
    $appName - Change this variable to the application you would like to close
               before the computer reboots
    
.NOTES
    Author: Keola McColgan
    Date Modified: 2024.04.09
    Removed else from appcheck
    Added funciton to delete screenshots
    Added reboot.log function

    Date Created: 2024.03.13
    Version 0.01
#>

$appName = "firefox"
$appToClose = Get-Process $appName -ErrorAction SilentlyContinue
$screenShotDir = ([System.Environment]::GetFolderPath("MyPictures") + "\Screenshots")
$logfileCheck = Get-Item -Path "D:\reboot.log" -ErrorAction SilentlyContinue

if ($appToClose) {
    (Get-Process -Name $($appName)).CloseMainWindow() | Out-Null
}

$vBoxManage = "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe"
$listRunningGuests = & $vBoxManage list runningvms

foreach ($runningGuest in $($listRunningGuests)){
    $runningGuest = $($runningGuest).split('"')[1]
    & $vBoxManage controlvm $($runningGuest) acpipowerbutton
}

Get-ChildItem $($screenShotDir) | Remove-Item

if ($($logFileCheck)) {
    Add-Content "D:\reboot.log" "Rebooted on - $(Get-Date -f 'yyyy.MM.dd') at $(Get-Date -f 'HHmm')"
} Else {
    New-Item "D:\reboot.log" -ErrorAction SilentlyContinue | Out-Null
    Add-Content "D:\reboot.log" "Rebooted on - $(Get-Date -f 'yyyy.MM.dd') at $(Get-Date -f 'HHmm')"
}
