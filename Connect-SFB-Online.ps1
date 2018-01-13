$credential = Get-Credential
Connect-MsolService -Credential $credential

# Find the root (onmicrosoft.com) tenant domain
Write-Host "Connected to MS Online Services, checking admin domain..." -ForegroundColor Yellow
$msolDomain = Get-MsolDomain | where {$_.Name -match "onmicrosoft.com" -and $_.Name -notmatch "mail.onmicrosoft.com"}

Write-Host "Admin domain found, connecting to $($msolDomain.Name)" -ForegroundColor Green

# Use this domain to connect to SFB Admin domain
$session = New-CsOnlineSession -Credential $credential -OverrideAdminDomain $msolDomain.Name
Import-PSSession $session