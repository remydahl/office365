<#
.DESCRIPTION
    This is a quick script to reset a WAP server configuration - helpful if your WAP server has lost trust to the ADFS server, and needs to be reset.

.PARAMETERS
    No parameters required, just run the script to reset your WAP Configuration.
    Before running the script for the first time, use this command to find your ADFS certificate thumbprint:

    Get-ChildItem -Path "Cert:\LocalMachine\My"
    
.NOTES
    File Name      : Reset-WAPConfig.ps1
    Author         : Jeremy Dahl (Jeremy.Dahl@masterandcmdr.com)
    Copyright 2018 - Master & Cmd-R

.EXAMPLE
    .\Reset-WAPConfig.ps1
#>

$creds = Get-Credential
$cert = "C9ADFCB04C432C4C0F213BA6DECBDB107B76F102" # replace this with your certificate thumbprint from above
$sts = "sts.masterandcmdr.com" #replace this with your Federation Service Name

# Set variables for updating the registry, in order to reset the WAP Config status
$regpath = "HKLM:\SOFTWARE\Microsoft\ADFS"
$keyname = "ProxyConfigurationStatus"
$keyvalue = "1"

# Reset WAP Configuration Status
New-ItemProperty -Path $regpath -Name $keyname -Value $keyvalue -PropertyType DWORD -Force

# Use this key to check the value of the registry key above.
# Get-ItemProperty -Path $regpath -Name $keyname

# Remove all old WAP certificates from the local store - a new one will be generated once trust is established
Set-Location Cert:\LocalMachine\My
Get-ChildItem | where {$_.Subject -match "CN=ADFS ProxyTrust"} | Remove-Item
Set-Location C:\

# Re-establish Federation Trust with the sts service.
Install-WebApplicationProxy -CertificateThumbprint $cert -FederationServiceName $sts -FederationServiceTrustCredential $creds