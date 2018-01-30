<#
.SYNOPSIS
    This script connects to the Exchange Online admin shell.

.DESCRIPTION
    The script checks to see if an existing Exchange Online PowerShell session exists, and doesn't attempt to reconnect if so. If no Exchange Online session is found,
    the script prompts for credentials, and then connects to the Exchange Online shell, as well as the MSOL Service.
    
.NOTES
    File Name      : Connect-ExchangeOnline.ps1
    Author         : Jeremy Dahl (Jeremy.Dahl@masterandcmdr.com)
    Copyright 2017 - Master & Cmd-R

.EXAMPLE
    Simply run this script by calling .\Connect-ExchangeOnline.ps1 in PowerShell.
#>

Write-Host "Checking for an existing connection to Exchange Online..." -ForegroundColor Yellow

$exSession = Get-PSSession | Where {$_.ComputerName -match "ps.outlook.com" -and $_.State -match "Opened"}
    if ($exSession.Count -ge 1){
        Write-Host "Connected!" -ForegroundColor Green
        }
    
    else {
        #Connect to Exchange Online
        Write-Host "Connecting to Exchange Online" -ForegroundColor Green
        $credential = Get-Credential
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $credential -Authentication Basic -AllowRedirection
        $importresults = Import-PSSession $Session -AllowClobber -DisableNameChecking
        Connect-MsolService -Credential $credential
        }