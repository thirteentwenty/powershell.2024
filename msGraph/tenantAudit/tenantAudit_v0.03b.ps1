<#
.SYNOPSIS
    Produces a list of the following
    1. Display, Given, and Sur names
    2. Assigned licenses
    3. User Principal Name
    4. Last signin
    5. User type (Member or Guest)
    6. Current mailbox size in GB

.DESCRIPTION
    Checks if you are connected to MsGrapn, if not it
    will prompt you to log in fetches basic user information

    1. Display, Given, and Sur names
    2. Assigned licenses
    3. User Principal Name
    4. Last signin
    5. User type (Member or Guest)
    6. Current mailbox size in GB

.PARAMETERS
    No parameters are needed

.EXAMPLE
    .\tenantAudit_v0.03.ps1

.NOTES
    Remove comments from the last few lines to enable to disable the following
    1. printToScreen - This shows the audit info in the PS window. You may want
    to disable this function as it can be fill up the screen on larger tenants
    2. Disconnect-MgGraph - Duh, this will disconnect your MgGraph session
    
    Update the connectToGraph function to reflect the Scopes
    needed for this script.

.NOTES
    Author: Keola McColgan
    Date Created: 2024.04.11
    Version 0.03
    Date Modified: 2024.04.22
    Fixed the sort method so it sorts by Display Name, then by User type (licensed/guest)
    Date Modified: 2024.04.18
    Sorted user audit by UserType (member/guest)
    Created function to collect mailbox size info (getMailboxUsage)
    Date Modified: 2027.04.19
    Converted process $licenseAudit to a function (getLicenseUsage)
    Created a function to combine the CSV files from the licenes usage report
    and the mailbox usage report.

    Version 0.02
    Date Modified: 2024.04.13
    Added check and toggle for name obfuscation of reports
    for mailbox statistics (to be added at a future date)
    the connection scope "Report.Read.All" is needed
    for this.

    Version 0.01
    Original Release date: 2024.04.11
#>
function connecToGraph {
    Connect-MgGraph -Scopes "User.Read.All","AuditLog.Read.All","Reports.Read.All" -NoWelcome
    Write-Host Tenant name - $($currentTenant) -ForegroundColor Gray -BackgroundColor Black
    Write-Host Tenant ID - $($tenantID) -ForegroundColor Gray -BackgroundColor Black
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
    (Get-ChildItem "$PSScriptRoot\tenantAudit-$($tenantFileName)_*.csv"  | Select-Object -First 1).FullName | Import-Csv | Format-List
}

function saveToHTML {
    getLicenseUsage| ConvertTo-Html | Out-File "$PSScriptRoot\licenseAudit-$($tenantFileName)_$($date).html"
}

function auditTenant {
    getLicenseUsage
    getMailboxUsage

    combineSources
}

function getLicenseUsage {
    $licenseAudit = foreach ($user in $($mgUserList) | Sort-Object @{Expression="UserType";Descending=$True},  @{Expression="DisplayName"; Descending=$False} ) {
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
    $($licenseAudit) | Export-Csv -Path "$PSScriptRoot\licenseAudit-$($tenantFileName)_$($date).csv" -NoTypeInformation

}

function getMailboxUsage {
    Get-MgReportMailboxUsageDetail -Period "D180" -Outfile "$PSScriptRoot\mailboxUsage-$($tenantFileName)_$($date).csv"
}

function combineSources {
    $accountDetails = @{}

    (Get-ChildItem "$PSScriptRoot\mailboxUsage-$($tenantFileName)_*.csv"  | Select-Object -First 1).FullName | Import-Csv | ForEach-Object { $accountDetails[$_."Display Name"] = [math]::round($_."Storage Used (Byte)" /1Gb, 2)  }
    (Get-ChildItem "$PSScriptRoot\licenseAudit-$($tenantFileName)_*.csv" | Select-Object -First 1).FullName | Import-Csv | Select-Object *, @{ Name='Storage Used (GB)'; Expression={$accountDetails[$_."Display Name"]}} | Export-Csv "tenantAudit-$($tenantFileName)_$($date).csv" -NoTypeInformation
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

If ((Get-MgBetaAdminReportSetting).DisplayConcealedNames -eq $True) {
    $Parameters = @{ DisplayConcealedNames = $False }
    Update-MgBetaAdminReportSetting -BodyParameter $Parameters
}

auditTenant
printToScreen
# disconnectFromGraph
