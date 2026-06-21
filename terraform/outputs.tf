# Outputs print useful values after deployment so you can confirm what
# was created without having to check the Azure portal manually.

output "compliant_device_policy_id" {
  description = "ID of the compliant device Conditional Access policy"
  value       = azuread_conditional_access_policy.require_compliant_device.id
}

output "block_noncompliant_policy_id" {
  description = "ID of the block non-compliant device policy"
  value       = azuread_conditional_access_policy.block_noncompliant_device.id
}

output "trusted_location_id" {
  description = "ID of the trusted office locations named location"
  value       = azuread_named_location.trusted_sites.id
}
