# ============================================
# Azure Container Registry
# ============================================

resource "azurerm_container_registry" "acr" {
  name                = "${var.project_name}${var.environment}ACR${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"  # Or "Standard" or "Premium"
  admin_enabled       = false    # Use managed identity instead
  
  tags = {
    Environment = var.environment
  }
}

resource "random_string" "acr_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Grant ACR Pull permission to Managed Identity
resource "azurerm_role_assignment" "aca_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
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