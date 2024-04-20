<#
.SYNOPSIS
    Produces a list of the following
    1. Display, Given, and Sur names
    2. Assigned licenses
    3. User Principal Name
    4. Last signin
    5. User type (Member or Guest)

.DESCRIPTION
    Checks if you are connected to MsGrapn, if not it
    will prompt you to log in fetches basic user information

    1. Display, Given, and Sur names
    2. Assigned licenses
    3. User Principal Name
    4. Last signin
    5. User type (Member or Guest)

.PARAMETERS
    No parameters are needed

.EXAMPLE
    .\tenantAudit_v0.01 <domain.tld>

.NOTES
    Author: Keola McColgan
    Date Created: 2024.04.11

    Version 0.01
    Original Release
#>
function connecToGraph {
    Connect-MgGraph -Scopes "User.Read.All","AuditLog.Read.All"-NoWelcome    
}

function disconnectFromGraph {
    Write-Host "Disconnecting from $($currentTenant)"
    Disconnect-MgGraph
}

function disconnectReconnect {
    Write-Host "Disconnecting from $($currentTenant)"
    Disconnect-MgGraph
    Start-Sleep 3
    connecToGraph
}

function selectConnectionAction {
    param (
        [string] $title = ''
    )
    Write-Host $($title)
    Write-host "Press 1 to stay connected to " -NoNewline
    Write-Host $($currentTenant) -ForegroundColor Yellow
    Write-Host "Press 2 to connect to a new tenant"
    Write-Host "Press 3 to disconnect"
}

function printToScreen {
    $($licenseAudit) | Format-List
}

function saveToCSV {
    $($licenseAudit) | Export-Csv -Path "$PSScriptRoot\licenseAudit-$($tenantFileName)_$($date).csv" -NoTypeInformation
}

function saveToHTML {
    $($licenseAudit) | ConvertTo-Html | Out-File "$PSScriptRoot\licenseAudit-$($tenantFileName)_$($date).html"
}

$currentTenant = Get-MgOrganization -ErrorAction SilentlyContinue
$currentTenant = $($currentTenant).DisplayName

if ($null -eq $($currentTenant)) {
    Write-Host you are not connected
    $confirmConnection = Read-Host "Do you want to connect? (y/n)"
    if ($($confirmConnection) -eq "y"){
        connecToGraph
    }
} else {
    Write-Host "You are conneted to " -ForegroundColor Gray -NoNewline
    Write-Host $($currentTenant) -ForegroundColor Yellow
    selectConnectionAction -title 'Select your connection action'
    $connectionAction = Read-Host "Please make a selection"
    switch ($($connectionAction)){
        '1' {
            Write-Host "Staying connected to " -NoNewline
            Write-Host $($currentTenant) -ForegroundColor Yellow
        } '2' {
            disconnectReconnect
        } '3' {
            disconnectFromGraph
        }
    }
}

$mgUserList = Get-MgUser -All -Property DisplayName, CreatedDateTime, GivenName, OtherMails, Mail, SignInActivity, Surname, UserPrincipalName, UserType
$date = (Get-Date -f 'yyyy.MM.dd-HHmm')
$tenantFileName = (Get-MgOrganization).DisplayName
$tenantFileName = $($tenantFileName).Replace(" ","_")
$tenantID = (Get-MgOrganization).Id

Write-Host Tenant name - $($currentTenant) -ForegroundColor Yellow -BackgroundColor Black
Write-Host Tenant ID - $($tenantID) -ForegroundColor Yellow -BackgroundColor Black

$licenseAudit =  foreach ($user in $($mgUserList)) {
    $userUPN = $($user).UserPrincipalName
    $userLicense = Get-MgUserLicenseDetail -UserId "$userUPN"
    [PSCustomObject]@{
        "Display Name" = $($user).DisplayName
        "User Principal Name" = $($user).UserPrincipalName
        "Email Address" = $($user).Mail
        "First Name" = $($user).GivenName
        "Last Name" = $($user).Surname
        "Date Created" = $($user).CreatedDateTime
        "Last Logon" = $($user).SignInActivity.LastSignInDateTime
        "Alternate email address" = $($user).OtherMails -join ","
        "License(s)" = $($userLicense).SkuPartNumber -join ","
        "User Type" = $($user).UserType
    }
}

printToScreen
#saveToCSV
#saveToHTML
# disconnectFromGraph
