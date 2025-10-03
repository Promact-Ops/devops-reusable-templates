# ALL RESOURCES REQUIRED FOR THIS INFRASTRUCTURE

# Random suffix for resource names
resource "random_string" "random_suffix" {
  length  = 5
  lower   = true
  upper   = false #keep it false as some resources dont support uppercase
  numeric = false #keep it false as some resources dont support numeric
  special = false #keep it false as some resources dont support special characters
}

# Resource group
resource "azurerm_resource_group" "resource_group" {
  name     = lower("${var.app_name}-${random_string.random_suffix.result}-rg")
  location = var.location
  tags     = var.tags
}

################################################################################################

## Virtual machine setup

# Virtual network
resource "azurerm_virtual_network" "virtual_network" {
  name                = lower("${var.app_name}-${random_string.random_suffix.result}-vnet")
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["${var.vnet_cidr}"]
  tags                = var.tags
  depends_on          = [azurerm_resource_group.resource_group]
}

# Automatically calculate subnet CIDR blocks (/28 blocks)
locals {
  vm_subnet_cidr = cidrsubnet("${var.vnet_cidr}", 12, 32)
  #database_subnet_cidr = cidrsubnet("${var.vnet_cidr}", 12, 48) # can be used later
  #bastion_subnet_cidr  = cidrsubnet("${var.vnet_cidr}", 12, 64) # can be used later
}

# Subnet for VM
resource "azurerm_subnet" "vm_subnet" {
  name                 = lower("${var.app_name}-${random_string.random_suffix.result}-vm-subnet")
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["${local.vm_subnet_cidr}"]
  depends_on           = [azurerm_virtual_network.virtual_network]
}

# Static public IP for the VM
resource "azurerm_public_ip" "static_public_ip" {
  name                = lower("${var.app_name}-${random_string.random_suffix.result}-public-ip")
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"   # Static for reserved IP, dynamic for ephemeral IP
  sku                 = "Standard" # Possible values are Standard or Basic
  sku_tier            = "Regional" # Possible values are Regional or Global
  tags                = var.tags
  depends_on          = [azurerm_resource_group.resource_group]
}

# Network security group and rule for SSH, HTTP, and HTTPS
resource "azurerm_network_security_group" "network_security_group" {
  name                = lower("${var.app_name}-${random_string.random_suffix.result}-nsg")
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "SSH-HTTP-HTTPS"
    description                = "Allow SSH, HTTP, and HTTPS traffic from anywhere"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags       = var.tags
  depends_on = [azurerm_resource_group.resource_group]
}

# Network interface for the VM
resource "azurerm_network_interface" "network_interface" {
  name                = lower("${var.app_name}-${random_string.random_suffix.result}-nic")
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "vm_nic_config"
    subnet_id                     = azurerm_subnet.vm_subnet.id # attach the subnet to the network interface
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static_public_ip.id # this is important to assign the staticpublic ip to the network interface
  }

  tags       = var.tags
  depends_on = [azurerm_resource_group.resource_group]
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "vm_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.network_interface.id
  network_security_group_id = azurerm_network_security_group.network_security_group.id
  depends_on                = [azurerm_network_interface.network_interface, azurerm_network_security_group.network_security_group]
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "linux_virtual_machine" {
  name = lower("${var.app_name}-${random_string.random_suffix.result}-vm")
  # computer_name         = "myapp-vm" # Specifies the Hostname which should be used for this Virtual Machine 
  location              = azurerm_resource_group.resource_group.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  size                  = var.vm_size # eg "Standard_DS1_v2"
  custom_data           = filebase64("${path.module}/vm-startup-script.sh")

  admin_username = "ubuntu"
  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.ssh_public_key # Replace with your actual public key
  }

  os_disk {
    name                 = lower("${var.app_name}-${random_string.random_suffix.result}-osdisk")
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    # disk_size_gb = 32 # The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from.
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = var.vm_image_version # eg "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags       = var.tags
  depends_on = [azurerm_resource_group.resource_group]
}


################################################################################################

# Random storage account name
resource "random_string" "random_storage_account_name" {
  length  = 18
  upper   = false
  lower   = true
  numeric = true
  special = false
}

# Storage account
resource "azurerm_storage_account" "storage_account" {
  name                             = "stgacc${random_string.random_storage_account_name.result}"
  resource_group_name              = azurerm_resource_group.resource_group.name
  location                         = azurerm_resource_group.resource_group.location
  public_network_access_enabled    = true
  cross_tenant_replication_enabled = true
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  account_kind                     = "StorageV2"
  tags                             = var.tags
  depends_on                       = [azurerm_resource_group.resource_group]
}


# Public container in storage account
resource "azurerm_storage_container" "storage_account_public_container" {
  name                  = "public-files"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "blob" # Possible values are blob, container or private. Defaults to private
  depends_on            = [azurerm_storage_account.storage_account]
}

# Private container in storage account
resource "azurerm_storage_container" "storage_account_private_container" {
  name                  = "private-files"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private" # Possible values are blob, container or private. Defaults to private
  depends_on            = [azurerm_storage_account.storage_account]
}

################################################################################################

## Managed PostgreSQL server setup

# Create a random username for the PostgreSQL server
resource "random_string" "random_postgres_admin_username" {
  length  = 10
  upper   = false
  lower   = true
  numeric = false
  special = false
}

# Create a random password for the PostgreSQL server
# Note: I have chosen random_string instead of random_password because I want the user to be able to use outputs to get and use the password
resource "random_string" "random_postgres_admin_password" {
  length  = 20
  upper   = true
  lower   = true
  numeric = true
  special = false
}

# Azure PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgres_server" {
  name                          = lower("${var.app_name}-${random_string.random_suffix.result}-dbserver")
  resource_group_name           = azurerm_resource_group.resource_group.name
  location                      = azurerm_resource_group.resource_group.location
  administrator_login           = random_string.random_postgres_admin_username.result
  administrator_password        = random_string.random_postgres_admin_password.result
  public_network_access_enabled = true # make it false if you want to use it in vnet

  backup_retention_days        = 35 # Possible values are between 7 and 35 days.
  geo_redundant_backup_enabled = true

  version           = var.postgres_version      # example - 16
  sku_name          = var.postgres_sku_name     # example - B_Standard_B2s, syntax - "sku_tier_name"
  storage_tier      = var.postgres_storage_tier # example - P10
  storage_mb        = var.postgres_storage_mb   # example - 32768
  auto_grow_enabled = true

  maintenance_window {
    day_of_week  = 0
    start_hour   = 2
    start_minute = 30
  }

  tags       = var.tags
  depends_on = [azurerm_resource_group.resource_group]
}


# Enable Vector extension since most apps need it nowadays
resource "azurerm_postgresql_flexible_server_configuration" "postgres_server_vector_extension_config" {
  name       = "azure.extensions"
  server_id  = azurerm_postgresql_flexible_server.postgres_server.id
  value      = "VECTOR"
  depends_on = [azurerm_postgresql_flexible_server.postgres_server]
}


# Creating database in PostgreSQL server
resource "azurerm_postgresql_flexible_server_database" "postgres_server_database" {
  name      = lower("${var.app_name}-db")
  server_id = azurerm_postgresql_flexible_server.postgres_server.id
  collation = "en_US.utf8"
  charset   = "utf8"
  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [azurerm_postgresql_flexible_server.postgres_server]
}

# Firewall rule for the PostgreSQL server
resource "azurerm_postgresql_flexible_server_firewall_rule" "postgres_server_firewall_rule" {
  name             = "postgres-server-firewall-rule"
  server_id        = azurerm_postgresql_flexible_server.postgres_server.id
  start_ip_address = var.postgres_server_firewall_allowed_start_ip_address
  end_ip_address   = var.postgres_server_firewall_allowed_end_ip_address
  depends_on       = [azurerm_postgresql_flexible_server.postgres_server]
}
