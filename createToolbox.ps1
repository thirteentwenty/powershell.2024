<#
.Synopsis
   Adds a new path to the Envrionment Variable Path on the machine level
.DESCRIPTION
   Creates the drectory for any CLI tools you would like to have on the target machine
   Adds a new path to the Envrionment Variable Path on the machine level
   
   Remove the comment block at the end to see the new list of Paths
.EXAMPLE
   Update the $toolboxLocation variable to the path you would like to add
   Then run in an elevated PowerShell window the following command
   .\createToolbox.ps1
#>
$toolboxLocation = "$env:ProgramData\Toolbox"

If(!(Test-Path -Path $($toolboxLocation))) {
   New-Item -ItemType Directory -Path $($toolboxLocation) | Out-Null
}

$newPath = [Environment]::GetEnvironmentVariable("PATH", "Machine") + [IO.Path]::PathSeparator + $toolboxLocation
[Environment]::SetEnvironmentVariable("Path",$newPath,"Machine")

<#
$showPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$showPath
#>
