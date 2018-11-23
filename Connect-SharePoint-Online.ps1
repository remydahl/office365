<#
.SYNOPSIS
    Use this script to connect to SharePoint Admin to perform administrative tasks throught PowerShell. 

.PARAMETER TenantName
    This Parameter is required, and is the base tenant name. For contoso.onmicrosoft.com, the base tenant name would be contoso, 
    and the SharePoint admin site would be "https://contoso-admin.sharepoint.com"

.NOTES
    File Name      : Connect-SharePoint-Online.ps1
    Author         : Jeremy Dahl (jdahl@masterandcmdr.com)
    Copyright 2015 - Jeremy Dahl

.EXAMPLE
    .\connect-SharePoint-Online.ps1 -TenantName Contoso
    This will connect to the Contoso SharePoint Admin URL, as well as the MSOL Service, so you can modify the users as well.
#>
# parameter

param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [String] $TenantName = ""
    )

$spoDomain = "https://" + $Tenantname
$spoDomain = $spoDomain + "-admin.sharepoint.com"

$objCreds = Get-Credential
Connect-SPOService -Url $spoDomain -credential $objCreds
Connect-MSOLService -credential $objCreds