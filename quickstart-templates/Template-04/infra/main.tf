terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 4.0"
        }
    }
}

provider "azurerm" {
    features {}
    subscription_id = var.subscribtion_id
}

resource "azurerm_resource_group" "rg" {
    name     = "${var.resource_group_name}"
    location = var.location
}


data "azurerm_user_assigned_identity" "aca_identity_data" {
  name                = azurerm_user_assigned_identity.aca_identity.name
  resource_group_name = azurerm_resource_group.rg.name
}


## VNet
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.project_name}-${var.environment}-vnet"
    address_space       = var.azurerm_virtual_network_address_space
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}


## Subnets
resource "azurerm_subnet" "aca_infra_subnet" {
    name                 = "${var.project_name}-${var.environment}-aca-infra-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = var.azurerm_subnet_aca_infra_subnet_cidr
}

resource "azurerm_subnet" "aca_app_subnet" {
    name                 = "${var.project_name}-${var.environment}-aca-app-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = var.azurerm_subnet_aca_app_subnet_cidr

    delegation {
        name = "delegation"

        service_delegation {
            name    = "Microsoft.App/environments"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
    }

}




## Log Analytics workspace (required for Container Apps env)
resource "azurerm_log_analytics_workspace" "law" {
    name                = "${var.project_name}-${var.environment}-law"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = "PerGB2018"
    retention_in_days   = 30
}


## Container Apps Environment with VNet integration
resource "azurerm_container_app_environment" "aca_env" {
    name                       = "${var.project_name}-${var.environment}-aca-env"
    location                   = azurerm_resource_group.rg.location
    resource_group_name        = azurerm_resource_group.rg.name
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
    infrastructure_subnet_id   = azurerm_subnet.aca_infra_subnet.id

}


## PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgresql" {
    name                   = "${var.project_name}${var.environment}flexibleserver"
    resource_group_name    = azurerm_resource_group.rg.name
    location               = azurerm_resource_group.rg.location
    
    version                = "16"
    # administrator_login    = "pgadmin"
    # administrator_password = "StrongP@ssw0rd!"
    authentication {
      active_directory_auth_enabled = true
      password_auth_enabled = false
      tenant_id = "6204282d-c27d-434a-82cb-330432f1de26"
    }
    zone = null

    storage_mb   = 32768
    storage_tier = "P4"

    sku_name   = "B_Standard_B1ms"


    public_network_access_enabled = false


}

# Subnet for PostgreSQL Private Endpoint
resource "azurerm_subnet" "postgresql_private_endpoint_subnet" {
  name                 = "${var.project_name}-${var.environment}-psql-private-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.azurerm_subnet_postgresql_private_endpoint_subnet_cidr
}


# Private Endpoint for PostgreSQL Flexible Server
resource "azurerm_private_endpoint" "postgresql_private_endpoint" {
    name                = "${var.project_name}-${var.environment}-psql-private-endpoint"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    subnet_id           = azurerm_subnet.postgresql_private_endpoint_subnet.id  # New subnet
    private_dns_zone_group {
        name                 = "postgresql-dns-zone-group"
        private_dns_zone_ids = [azurerm_private_dns_zone.postgresql_private_dns.id]
    }
    
    private_service_connection {
        name                           = "postgresql-psc"
        private_connection_resource_id = azurerm_postgresql_flexible_server.postgresql.id
        is_manual_connection           = false
        subresource_names              = ["postgresqlServer"]
    }
}


# Private DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgresql_private_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

# Link VNet to Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_dns_link" {
    name                  = "${var.project_name}-${var.environment}-psql-dns-link"
    resource_group_name   = azurerm_resource_group.rg.name
    private_dns_zone_name = azurerm_private_dns_zone.postgresql_private_dns.name
    virtual_network_id    = azurerm_virtual_network.vnet.id
    registration_enabled = true
}



data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

# Get current user/service principal details for PostgreSQL Admin
data "azuread_user" "current" {
  object_id = data.azuread_client_config.current.object_id
}







# Set Entra ID Administrator for PostgreSQL Application - Application (Service Principal)
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "postgres_admin" {
  server_name         = azurerm_postgresql_flexible_server.postgresql.name
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_user_assigned_identity.aca_identity_data.principal_id
  principal_name      = azurerm_user_assigned_identity.aca_identity.name
  principal_type      = "ServicePrincipal"

    depends_on = [
        azurerm_postgresql_flexible_server.postgresql
    ]
}



# User-Assigned Managed Identity for Container App (better control than system-assigned)
resource "azurerm_user_assigned_identity" "aca_identity" {
    name                = "${var.project_name}-${var.environment}-aca-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  
}


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
  value       = {
    vnet = azurerm_virtual_network.vnet
    aca_infra_subnet = azurerm_subnet.aca_infra_subnet
    aca_app_subnet = azurerm_subnet.aca_app_subnet
    postgresql_private_endpoint_subnet = azurerm_subnet.postgresql_private_endpoint_subnet
  }
  description = "Virtual Network ID"
  
}