<#
.SYNOPSIS
    This script creates a secure XML credentials file that can be used to log in to Office 365, greatly simplifying scripting automation.

.DESCRIPTION
    The script prompts for username and password - the password is encrypted as a SecureString, but needs to be passed along to the new system object in plain text.
    After the password is saved as an encrypted XML file, the admPassword variable is cleared to ensure that the password is not discoverable from the shell.

    If necessary, change the $credFilePath variable to match the location you'd like to save the xml file to - if unchanged, the xml will be saved to the current directory.

    
.NOTES
    File Name      : Create-AdminCredentials.ps1
    Author         : Jeremy Dahl (Jeremy.Dahl@masterandcmdr.com)

.EXAMPLE
    Simply run this script by calling .\Create-AdminCredentials.ps1 from an admin shell.
#>

$credFilePath = ".\O365Credential.xml" #xml file that holds the global admin login information

$admAccount = Read-Host "Enter admin logon (UPN)"
$admPassword = Read-Host -AsSecureString "Please enter admin password"
$admPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($admPassword)) 

New-Object System.Management.Automation.PSCredential($admAccount, (ConvertTo-SecureString -AsPlainText -Force $admPassword)) | Export-CliXml $credFilePath

$admPassword = $null
