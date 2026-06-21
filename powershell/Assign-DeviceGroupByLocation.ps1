# 
.SYNOPSIS
    Assigns a device to the correct Entra ID group based on its site location.

.DESCRIPTION
    Reads a device's location tag (set during enrolment or via an Intune
    extension attribute) and adds it to the matching Entra ID dynamic-style
    group, so the right Conditional Access and compliance profile applies
    automatically without manual intervention per site.

.NOTES
    Author:  Gurpreet Singh
    Version: 1.0
    Requires: Microsoft.Graph PowerShell module
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$DeviceId,

    [Parameter(Mandatory = $true)]
    [string]$SiteTag
)

# Maps each site tag to its corresponding Entra ID group object ID.
# In a real environment, these would be pulled from a config file or
# Key Vault rather than hardcoded here.
$siteGroupMap = @{
    "SiteA" = "00000000-0000-0000-0000-000000000001"
    "SiteB" = "00000000-0000-0000-0000-000000000002"
    "SiteC" = "00000000-0000-0000-0000-000000000003"
}

if (-not $siteGroupMap.ContainsKey($SiteTag)) {
    Write-Error "No matching group found for site tag '$SiteTag'. Check the mapping table."
    exit 1
}

$targetGroupId = $siteGroupMap[$SiteTag]

try {
    New-MgGroupMember -GroupId $targetGroupId -DirectoryObjectId $DeviceId
    Write-Output "Device $DeviceId assigned to group for $SiteTag (Group ID: $targetGroupId)"
}
catch {
    Write-Error "Failed to assign device $DeviceId to group: $_"
    exit 1
}
