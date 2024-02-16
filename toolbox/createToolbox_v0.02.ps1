<#
.Synopsis
   Adds a new path to the Envrionment Variable Path on the machine level
.DESCRIPTION
   Creates the drectory for any CLI tools you would like to have on the target machine
   Adds a new path to the Envrionment Variable Path on the machine level
   
   Remove the comment block at the end to see the new list of Paths
.EXAMPLE
   .\createToolbox.ps1
.NOTES
    Author: Keola McColgan
    Modified date: 2024.02.15
    Version 0.01

   Update the $toolboxLocation variable to the path you would like to add
   The default is to create C:\ProgramData\Toolbox

   2024.02.15 - 1501
   Version 0.02
   Added tool download functions
    Download tools from your private repository
    update the $downloadURL variable to your repository location
    update the $toolList array with the tools you would like to download

   Added function to check if the environment path exists 
#>
$toolboxLocation = "$env:ProgramData\Toolbox"
$downloadURL = "https://pathTo.tld/Files"

$toolList = @(
    ("fileName1.exe");
    ("fileName1.exe");
    ("fileName1.exe")
)

$envPathVars = [Environment]::GetEnvironmentVariable("PATH", "Machine") -split ";"

if (!($envPathVars -contains $toolboxLocation)) {
    $newPath = [Environment]::GetEnvironmentVariable("PATH", "Machine") + [IO.Path]::PathSeparator + $toolboxLocation
    [Environment]::SetEnvironmentVariable("Path",$newPath,"Machine")
}

If(!(Test-Path -Path $($toolboxLocation))) {
   New-Item -ItemType Directory -Path $($toolboxLocation) | Out-Null
}

forEach ($tool in $($toolList)) {
    Write-Host Downloading $($tool)
    $payLoad = $($downloadURL) + $($tool)
    Start-BitsTransfer -Source $($payLoad) -Destination $($toolboxLocation)
}

<#
$showPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$showPath
#>
