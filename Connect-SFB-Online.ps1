<#
.SYNOPSIS
    This script connects to the Skype for Business admin shell, specifying the admin domain to connect to.

.DESCRIPTION
    The script prompts for credentials, and then connects to the MSOL Service in order to locate the root tenant domain. This domain is then used 
    to specify the OverrideAdminDomain parameter.
    
.NOTES
    File Name      : Connect-SFB-Online.ps1
    Author         : Jeremy Dahl (Jeremy.Dahl@masterandcmdr.com)
    Copyright 2017 - Master & Cmd-R


.EXAMPLE
    Simply run this script by calling .\Connect-SFB-Online in PowerShell

#>
$credential = Get-Credential
Connect-MsolService -Credential $credential

# Find the root (onmicrosoft.com) tenant domain
Write-Host "Connected to MS Online Services, checking admin domain..." -ForegroundColor Yellow
$msolDomain = Get-MsolDomain | where {$_.Name -match "onmicrosoft.com" -and $_.Name -notmatch "mail.onmicrosoft.com"}

Write-Host "Admin domain found, connecting to $($msolDomain.Name)" -ForegroundColor Green

# Use this domain to connect to SFB Admin domain
$session = New-CsOnlineSession -Credential $credential -OverrideAdminDomain $msolDomain.Name
Import-PSSession $session
