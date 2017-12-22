
$credpath = ".\O365Credential.xml"
$admAccount = "user@domain.com"
$admPassword = "admpassword"

New-Object System.Management.Automation.PSCredential($adminAccount, (ConvertTo-SecureString -AsPlainText -Force $admPassword)) | Export-CliXml $credpath 

$credFilePath = ".\O365Credential.xml" #xml file that holds the global admin login information
 
#Login credential to Office 365 with admin rights
$credential = Import-Clixml -Path $credFilePath 