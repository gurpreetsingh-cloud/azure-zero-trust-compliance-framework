# This file defines the core Conditional Access policy for the Zero Trust
# framework. It enforces two things together: the device must be marked
# compliant by Intune, AND access from outside trusted site locations
# requires MFA on top of that.

resource "azuread_named_location" "trusted_sites" {
  display_name = "Trusted Office Locations"

  ip {
    ip_ranges = var.trusted_site_ip_ranges
    trusted   = true
  }
}

resource "azuread_conditional_access_policy" "require_compliant_device" {
  display_name = "Require Compliant Device for Resource Access"
  state        = "enabled"

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_groups = [var.target_device_group_id]
    }

    locations {
      included_locations = ["All"]
      excluded_locations  = [azuread_named_location.trusted_sites.id]
    }
  }

  grant_controls {
    operator          = "AND"
    built_in_controls = ["compliantDevice", "mfa"]
  }
}

resource "azuread_conditional_access_policy" "block_noncompliant_device" {
  display_name = "Block Access for Non-Compliant Devices"
  state        = "enabled"

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_groups = [var.target_device_group_id]
    }

    devices {
      filter {
        mode = "exclude"
        rule = "device.deviceIsCompliant -eq True"
      }
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}
