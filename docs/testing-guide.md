# Testing Guide

How I'd validate this setup actually works as intended, rather than just
assuming it does because `terraform apply` ran without errors.

## 1. Confirm the policies deployed correctly

```bash
terraform output
```

This prints the policy IDs and named location ID from `outputs.tf`. Cross-check
these against the Entra ID admin center (Protection > Conditional Access) to
confirm they match what was actually created.

## 2. Test the compliant device path

- Enrol a test device, intentionally configured to fail one compliance
  check (e.g. BitLocker disabled)
- Attempt to access a protected resource (e.g. SharePoint or the Azure portal)
- Expected result: access is blocked, and after the 24-hour grace period
  defined in `device-compliance-policy.json`, the device shows as
  non-compliant in Intune

## 3. Test the location-based path

- From a connection outside the trusted IP ranges defined in
  `variables.tf`, attempt access with a compliant device
- Expected result: MFA prompt appears, since the policy requires both
  compliance and MFA outside trusted locations
- From inside a trusted IP range, the same compliant device should not
  be prompted for MFA by this policy

## 4. Test the PowerShell scripts independently

`Assign-DeviceGroupByLocation.ps1`:
```powershell
.\Assign-DeviceGroupByLocation.ps1 -DeviceId "<test-device-id>" -SiteTag "SiteA"
```
Confirm the device appears in the correct Entra ID group afterward.

`Set-LocalAdminProfile.ps1`:
```powershell
$pw = Read-Host -AsSecureString "Enter password"
.\Set-LocalAdminProfile.ps1 -SiteTag "SiteA" -AccountPassword $pw
```
Confirm the account appears under Local Users and Groups, and check the
log file at `C:\ProgramData\ZeroTrustAutomation\admin-provisioning.log`
for the audit entry.

## What I'd add for a production rollout
This is manual validation, suitable for a portfolio project. For a real
deployment, these checks would be automated with Pester (PowerShell's
testing framework) for the scripts, and `terraform plan` would run in a
CI pipeline before any apply, so policy changes get reviewed before they
go live rather than tested only after the fact.
