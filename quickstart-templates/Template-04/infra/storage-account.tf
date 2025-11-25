# ============================================
# Storage Account with Private Endpoint
# ============================================

resource "azurerm_storage_account" "storage" {
  name = substr(
    regexreplace(
      lower("${var.project_name}${var.environment}storage${random_string.storage_suffix.result}"),
      "[^a-z0-9]",
      ""
    ),
    0,
    24
  )

  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Security best practices
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false # Private endpoint only

  # Enable blob versioning and soft delete
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = {
    Environment = "Production"
    Purpose     = "ACA-Storage-Integration"
  }
}

# Random suffix for globally unique storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Blob container for testing
resource "azurerm_storage_container" "test_container" {
  name                  = "test-files"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

# Additional containers for different purposes
resource "azurerm_storage_container" "uploads_container" {
  name                  = "uploads"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "logs_container" {
  name                  = "logs"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}


# ============================================
# Private Endpoint for Storage Account
# ============================================

# Subnet for Storage Private Endpoint
resource "azurerm_subnet" "storage_private_endpoint_subnet" {
  name                 = "${var.project_name}-${var.environment}-storage-private-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.azurerm_subnet_storage_private_endpoint_subnet_cidr
}

# Private Endpoint for Blob Storage
resource "azurerm_private_endpoint" "storage_blob_private_endpoint" {
  name                = "${var.project_name}-${var.environment}-storage-blob-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.storage_private_endpoint_subnet.id

  private_dns_zone_group {
    name                 = "blob-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_blob_private_dns.id]
  }

  private_service_connection {
    name                           = "storage-blob-psc"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

# Private DNS Zone for Blob Storage
resource "azurerm_private_dns_zone" "storage_blob_private_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# Link VNet to Blob Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob_dns_link" {
  name                  = "${var.project_name}-${var.environment}-storage-blob-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob_private_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}


# ============================================
# RBAC: Grant Storage Permissions to Managed Identity
# ============================================

# Storage Blob Data Contributor role (Full CRUD access to blobs)
resource "azurerm_role_assignment" "aca_storage_blob_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

# Storage Account Contributor (for account-level operations)
resource "azurerm_role_assignment" "aca_storage_account_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

# Storage Queue Data Contributor (if you need queue access)
resource "azurerm_role_assignment" "aca_storage_queue_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

# Storage Table Data Contributor (if you need table access)
resource "azurerm_role_assignment" "aca_storage_table_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}


