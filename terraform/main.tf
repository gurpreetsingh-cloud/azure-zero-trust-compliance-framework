# Entry point for the Terraform configuration. This tells Terraform which provider to use to talk to Entra ID and pins a version so the code behaves consistently regardless of when or where it's run.

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azuread" {
  # Authentication is handled via environment variables or Azure CLI
  # login when this is actually applied — no credentials are stored
  # in this file.
}
