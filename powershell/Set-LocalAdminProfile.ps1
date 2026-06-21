# 
<#
.SYNOPSIS
    Provisions a site-scoped local administrator account on a device.

.DESCRIPTION
    Creates a local admin account using a naming convention tied to the
    site, rather than a single shared global admin account. This limits
    the blast radius if one site's credentials are ever compromised, in
    line with the least-privilege principle behind this Zero Trust setup.

.NOTES
    Author:  Gurpreet Singh
    Version: 1.0
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SiteTag,

    [Parameter(Mandatory = $true)]
    [SecureString]$AccountPassword
)

# Naming convention keeps the account identifiable per site for audit
# purposes, e.g. "ladmin-SiteA"
$accountName = "ladmin-$SiteTag"

try {
    $existingAccount = Get-LocalUser -Name $accountName -ErrorAction SilentlyContinue

    if ($existingAccount) {
        Write-Output "Account $accountName already exists. Updating password only."
        Set-LocalUser -Name $accountName -Password $AccountPassword
    }
    else {
        New-LocalUser -Name $accountName `
            -Password $AccountPassword `
            -FullName "Local Admin - $SiteTag" `
            -Description "Site-scoped local admin account, managed via automation"

        Add-LocalGroupMember -Group "Administrators" -Member $accountName
        Write-Output "Created local admin account: $accountName"
    }
}
catch {
    Write-Error "Failed to provision local admin account for $SiteTag : $_"
    exit 1
}

# Audit log entry — in production this would write to a centralised log
# (e.g. Azure Monitor / Log Analytics) rather than a local file.
$logEntry = "$(Get-Date -Format o) - Local admin account '$accountName' provisioned/updated on $env:COMPUTERNAME"
Add-Content -Path "C:\ProgramData\ZeroTrustAutomation\admin-provisioning.log" -Value $logEntry
