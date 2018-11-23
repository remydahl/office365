<#
.SYNOPSIS
    This script connects to the Security and Compliance Center admin shell.

.DESCRIPTION
    The script checks to see if an existing connection to the Security & Compliance Center exists, and doesn't attempt to reconnect if so. If no S&C session is found,
    the script prompts for credentials, and then connects to the compliance.protection.outlook.com URI, as well as the MSOL Service.
    
.NOTES
    File Name      : Connect-ComplianceCenter.ps1
    Author         : Jeremy Dahl (Jeremy.Dahl@masterandcmdr.com)
    Copyright 2018 - Master & Cmd-R

.EXAMPLE
    Simply run this script by calling .\Connect-ComplianceCenter.ps1 in PowerShell.
#>

Write-Host "Checking for an existing connection to the Security & Compliance Center..." -ForegroundColor Yellow

$exSession = Get-PSSession | Where {$_.ComputerName -match "ps.compliance.protection.outlook.com" -and $_.State -match "Opened"}
    if ($exSession.Count -ge 1){
        Write-Host "Connected!" -ForegroundColor Green
        }
    
    else {
        #Connect to the Security & Compliance Center
        Write-Host "Connecting to the Security and Compliance Center" -ForegroundColor Green
        $UPN = Read-Host "Enter the UPN of the user you want to connect with"
        Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
        $EXOSession = New-ExoPSSession -ConnectionUri "https://ps.compliance.protection.outlook.com/PowerShell-LiveId" -UserPrincipalName $UPN
        Import-PSSession $EXOSession
        }
""
Write-Host "Checking for an existing connection to Azure AD..." -ForegroundColor Yellow
$msol = Get-MsolDomain -ErrorAction SilentlyContinue | ? {$_.Name -match "onmicrosoft.com" -and $_.Name -notmatch "mail.onmicrosoft.com"}

    if (!$msol){
        # Connect to the MSOL Service - note that Connect-MsolService still does not support passing along credentials with Modern Auth
        Write-Host "Not connected to Azure AD, connecting now..." -ForegroundColor Magenta
        Write-Host "Note that the Azure AD module does not support passing along credentials with Modern Authentication"
        Connect-MsolService
        }
    
    else {Write-Host "Connected to $($msol.Name)" -ForegroundColor Green}
    		