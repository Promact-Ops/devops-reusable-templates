# Output Managed Identity details
output "aca_identity" {
  value       = azurerm_user_assigned_identity.aca_identity
  description = "Managed Identity"
}

# Output PostgreSQL Flexible Server details
output "postgresql_flexible_server" {
  value       = azurerm_postgresql_flexible_server.postgresql
  description = "PostgreSQL Flexible Server"
}

output "aca_environment" {
  value       = azurerm_container_app_environment.aca_env
  description = "Container Apps Environment"

}

output "vnet_id_and_subnets" {
  value = {
    vnet                               = azurerm_virtual_network.vnet
    aca_infra_subnet                   = azurerm_subnet.aca_infra_subnet
    aca_app_subnet                     = azurerm_subnet.aca_app_subnet
    postgresql_private_endpoint_subnet = azurerm_subnet.postgresql_private_endpoint_subnet
  }
  description = "Virtual Network ID"

}

# Output ACR details
output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "ACR Login Server URL"
}

output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "ACR Name"
}


# ============================================
# Outputs for Reference
# ============================================

output "storage_details" {
  value = {
    account = {
      full_resource         = azurerm_storage_account.storage
      name                  = azurerm_storage_account.storage.name
      primary_blob_endpoint = azurerm_storage_account.storage.primary_blob_endpoint
    }
    containers = {
      test_files = azurerm_storage_container.test_container.name
      uploads    = azurerm_storage_container.uploads_container.name
      logs       = azurerm_storage_container.logs_container.name
    }
  }
  description = "Storage account with all related containers and endpoints"
}