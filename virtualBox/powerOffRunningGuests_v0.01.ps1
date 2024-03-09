<#
.Synopsis
    This script will list the running VirtualBox Guest OS's
.DESCRIPTION
	
.EXAMPLE
    .\powerOffRunningGuests.ps1
.NOTES
    - Variables
    $vBoxManage -   This is the location of VBoxManage.exe, you shouldn't
                    have to modify this but may need to depending on
                    your installation    
.NOTES
    Author: Keola McColgan
    Date Created: 2024.03.10
    
    Modified Date 2024.03.10 
    Version 0.01

#>

$vBoxManage = "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe"
$listRunningGuests = & $vBoxManage list runningvms

foreach ($runningGuest in $($listRunningGuests)){
    $runningGuest = $($runningGuest).split('"')[1]
    & $vBoxManage controlvm $($runningGuest) acpipowerbutton
}

#$($listRunningGuests)
