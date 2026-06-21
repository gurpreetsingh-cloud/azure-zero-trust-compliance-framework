# Variables let the same Terraform code be reused across environments
# without hardcoding values directly into the policy files

variable "trusted_site_ip_ranges" {
  description = "Public IP ranges for office locations treated as trusted"
  type        = list(string)
  default     = ["203.0.113.0/24", "198.51.100.0/24"]
}

variable "target_device_group_id" {
  description = "Object ID of the Entra ID group this policy applies to"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}
