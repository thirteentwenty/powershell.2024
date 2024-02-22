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
   
   2024.02.21
   Version 0.03
   Added error control for BITS to fail more elegantly
#>
$toolboxLocation = "$env:ProgramData\Toolbox"
$downloadURL = "https://dlc.cetra.us/toolbox/"

$toolList = @(
    ("etl2pcapng.exe");
    ("speedtest.exe");
    ("speedtest.md")
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
    $payLoad = $($downloadURL) + $($tool)
    Try {
        # Write-Host Downloading $($tool)
        Start-BitsTransfer -Source $($payLoad) -Destination $($toolboxLocation) -ErrorAction Stop
    } catch [System.Exception] {
        if ($error[0] -match "HTTP status 404") {
            "404 File not found: $($tool)"
            'Please check the file name and try again'
            # $error[0].exception.message
        } else {
            $error[0].exception.message
        }
    } catch {
        'Failed to transfer with BITS. Here is the error message:'
        $error[0].exception.message
    }
}

<#
$showPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$showPath
#>
