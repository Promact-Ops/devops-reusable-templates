# Terraform and Provider Version Requirements

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.47.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = var.subscription_id # Can be found in subscriptions
  client_id       = var.client_id       # Client id is the application ID
  client_secret   = var.client_secret   # Client secret is inside Client credentials
  tenant_id       = var.tenant_id       # Tenant ID is directory ID 
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false # This will destroy resource group even if it contains resources
    }
  }
}
