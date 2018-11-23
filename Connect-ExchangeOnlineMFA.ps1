<#
.SYNOPSIS
    This script connects to the Exchange Online admin shell.

.DESCRIPTION
    The script checks to see if an existing Exchange Online PowerShell session exists, and doesn't attempt to reconnect if so. If no Exchange Online session is found,
    the script prompts for credentials, and then connects to the Exchange Online shell, as well as the MSOL Service.
    
.NOTES
    File Name      : Connect-ExchangeOnline.ps1
    Author         : Jeremy Dahl (Jeremy.Dahl@masterandcmdr.com)
    Copyright 2018 - Master & Cmd-R

.EXAMPLE
    Simply run this script by calling .\Connect-ExchangeOnline.ps1 in PowerShell.
#>

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
        $EXOSession = New-ExoPSSession -UserPrincipalName $UserCredential.UserName
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