<#
.DESCRIPTION
    This script can be used to set, remove and check SMTP forwarding for users in Office 365.

.PARAMETERS
    The only required parameter is the CSV file - if no other switches are specified, the script will simply check the users in the CSV
    and report back their forwarding status. The two switches available are SetForwarding and RemoveForwarding, which do exactly what you'd think they do ;)
    
.NOTES
    File Name      : Bulk-Forwarding.ps1
    Author         : Jeremy Dahl (Jeremy.Dahl@masterandcmdr.com)
    Copyright 2018 - Master & Cmd-R

.EXAMPLE
    .\Bulk-Forwarding.ps1 -csv C:\users.csv
      This will import the "C:\Users.csv" file and check the users on the file to verify their existing forwarding status. The CSV file must contain the UserPrincipalName and ForwardingAddress fields

    .\Bulk-Forwarding.ps1 -csv C:\users.csv -SetForwarding
      Imports this list of users and configures their accounts to forward to the forwarding addresses provided.

    .\Bulk-Forwarding.ps1 -csv C:\users.csv
      Imports this list of users and removes the forwarding address from their accounts.
#>

param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string] $Csv = "",
    [Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [switch] $SetForwarding,
    [Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [switch] $RemoveForwarding
)

$Users = Import-Csv $Csv

#region Connection Script
Write-Host "Checking for an existing connection to Exchange Online..." -ForegroundColor Yellow

$exSession = Get-PSSession | Where {$_.ComputerName -match "outlook.office365.com" -and $_.State -match "Opened"}
    if ($exSession.Count -ge 1){
        Write-Host "Connected!" -ForegroundColor Green
        }
    
    else {
        #Connect to Exchange Online
        Write-Host "Connecting to Exchange Online" -ForegroundColor Green
        $UPN = Read-Host "Enter the UPN of the user you want to connect with"
        Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
        $EXOSession = New-ExoPSSession -UserPrincipalName $UPN
        Import-PSSession $EXOSession
        }
""
Write-Host "Checking for an existing connection to Azure AD..." -ForegroundColor Yellow
$msol = Get-MsolDomain -ErrorAction SilentlyContinue | ? {$_.Name -match "onmicrosoft.com" -and $_.Name -notmatch "mail.onmicrosoft.com"}

    if (!$msol){
        # Connect to the MSOL Service - note that Connect-MsolService still does not support passing along credentials with Modern Auth
        Write-Host "Not connected to Azure AD, connecting now..." -ForegroundColor Magenta
        Connect-MsolService
        }
    
    else {Write-Host "Connected to $($msol.Name)" -ForegroundColor Green}
#endregion Connection Script

foreach ($u in $Users){
    $info = Get-Mailbox $u.UserPrincipalName
    $forward = $u.forwardingaddress

    if ($SetForwarding){

    ""
    Write-Host "Fetching $($info.DisplayName)'s user information" -ForegroundColor Magenta

            if (!$info.ForwardingSMTPAddress){
                Write-Host $info.DisplayName "is not configured for forwarding, adding it now..." -ForegroundColor Yellow
                Set-Mailbox $info.alias -DeliverToMailboxAndForward $false -ForwardingSmtpAddress $forward
                Get-Mailbox $u.UserPrincipalName | FL Name,Alias,PrimarySMTPAddress,ForwardingSMTPAddress,DeliverToMailboxandForward
                }

            else {
                Write-Host $info.DisplayName "is already forwarding emails to $($info.ForwardingSmtpAddress)" -ForegroundColor Magenta
                Get-Mailbox $u.UserPrincipalName | FL Name,Alias,PrimarySMTPAddress,ForwardingSMTPAddress,DeliverToMailboxandForward
                }
            }

    elseif ($RemoveForwarding){
    ""
            Write-Host "Removing the SMTP forwarding from $($info.DisplayName)'s account..." -ForegroundColor Yellow
            Set-Mailbox -Identity $u.UserPrincipalName -DeliverToMailboxAndForward $false -ForwardingSMTPAddress $null

            Write-Host "Fetching $($info.DisplayName)'s user information" -ForegroundColor Magenta
            Get-Mailbox $u.UserPrincipalName | FL Name,Alias,PrimarySMTPAddress,ForwardingSMTPAddress,DeliverToMailboxandForward
        }

    else {
        ""
        Write-Host "Fetching $($info.DisplayName)'s user information" -ForegroundColor Magenta
        Get-Mailbox $u.UserPrincipalName | FL Name,Alias,PrimarySMTPAddress,ForwardingSMTPAddress,DeliverToMailboxandForward
        }
      }