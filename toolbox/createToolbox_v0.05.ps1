<#
.Synopsis
    Adds a new path to the Envrionment Variable Path on the machine level
.DESCRIPTION
    Creates the drectory for any CLI tools you would like to have on the target machine
    Adds a new path to the Envrionment Variable Path on the machine level
   
    Uncomment the last line to view the new list of Environment Paths
.EXAMPLE
    .\createToolbox.ps1
.NOTES
    Variables and arrays to update
    
    - Variables
        $toolboxLocation    ::    This is the location on the local machine that you want to store your tools.
        $downloadURL        ::    This is the web, or network location your tools are located.
    - Array
        $toolList           ::    This is the list of files that you want transferred to you local machine.
.NOTES
    Author: Keola McColgan
    Date Created: 2024.02.15
    
    Modified date: 2024.04.17
    Version 0.05
    Updated the method that the Envrionmental variable 'PATH' is set
    to preserve %SystemRoot%

    Modified date: 2024.02.21
    Version 0.04
    Removed repeated lines of code that shows the current Environment Paths

    Modified date: 2024.02.21
    Version 0.03
    Added error control for BITS to fail more elegantly
    Added notes on about the variables and array used

    Modified date: 2024.02.15
    Version 0.02
    Added tool download functions
    Download tools from your private repository
        -- update the $downloadURL variable to your repository location
        -- update the $toolList array with the tools you would like to download
    
    Modified date: 2024.02.15 - 1501
    Added function to check if the environment path exists 

    Version 0.01
    Update the $toolboxLocation variable to the path you would like to add
    The default is to create C:\ProgramData\Toolbox
#>
$toolboxLocation = "$env:ProgramData\Toolbox"
$downloadURL = "https://dlc.cetra.us/toolbox/"

$toolList = @(
    ("etl2pcapng.exe"),
    ("putty.exe"),
    ("speedtest.exe"),
    ("speedtest.md")
)

$envPathVars = [Environment]::GetEnvironmentVariable("PATH", "Machine") -split ";"

if (!($envPathVars -contains $toolboxLocation)) {
    $pathKey = Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    $toolboxLocation = "$env:ProgramData\Toolbox"
    $currentPath = $($pathKey).GetValue('PATH','', 'DoNotExpandEnvironmentNames')
    $newPath = "$($currentPath);$($toolboxLocation)"
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $($newPath) -Force
}

If(!(Test-Path -Path $($toolboxLocation))) {
   New-Item -ItemType Directory -Path $($toolboxLocation) | Out-Null
}

forEach ($tool in $($toolList)) {
    $payLoad = $($downloadURL) + $($tool)
    Try {
        # Write-Host Downloading $($tool)
        Start-BitsTransfer -Source $($payLoad) -Destination $($toolboxLocation) -ErrorAction Stop
    } catch [System.Exception] {
        if ($error[0] -match "HTTP status 404") {
            "404 File not found: $($tool)"
            'Please check the file name and try again'
            'Please rerun the script'
            # $error[0].exception.message
        } else {
            $error[0].exception.message
        }
    } catch {
        'Failed to transfer with BITS. Here is the error message:'
        $error[0].exception.message
    }
}
# $envPathVars
