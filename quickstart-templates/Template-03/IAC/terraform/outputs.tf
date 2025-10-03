# Outputs for the Terraform configuration

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.resource_group.name
}

output "resource_location" {
  description = "The location of all the resources"
  value       = azurerm_resource_group.resource_group.location
}

########################################################################################
# Outputs for the virtual machine

output "public_ip_address" {
  description = "The staticpublic IP address of the virtual machine"
  value       = azurerm_public_ip.static_public_ip.ip_address
}

output "virtual_machine_admin_username" {
  description = "The admin username of the virtual machine"
  value       = "ubuntu"
}

output "virtual_machine_admin_password" {
  description = "The admin password/key of the virtual machine"
  value       = "Use your private ssh key to login to the VM, eg ssh -i <path-to-your-private-key> ubuntu@<public-ip-address>"
}

########################################################################################
# Outputs for the storage account

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.storage_account.name
}

output "storage_account_primary_connection_string" {
  description = "The primary connection string of the storage account"
  value       = "Go to azure portal and go to the storage account and click on the connection string button to get the connection string OR ask devops team"
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the storage account"
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}

output "storage_account_public_container_name" {
  description = "The name of the public container in the storage account"
  value       = azurerm_storage_container.storage_account_public_container.name
}

output "storage_account_private_container_name" {
  description = "The name of the private container in the storage account"
  value       = azurerm_storage_container.storage_account_private_container.name
}

########################################################################################
# Outputs for the PostgreSQL server

output "postgres_server_name" {
  description = "The name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.postgres_server.name
}

output "postgres_server_endpoint" {
  description = "The endpoint of the PostgreSQL server"
  value       = "${var.app_name}-${random_string.random_suffix.result}-dbserver.postgres.database.azure.com"
}

output "postgres_server_admin_username" {
  description = "The admin username of the PostgreSQL server"
  value       = random_string.random_postgres_admin_username.result
}

output "postgres_server_admin_password" {
  description = "The admin password of the PostgreSQL server"
  value       = random_string.random_postgres_admin_password.result
}

output "postgres_server_database_name" {
  description = "The name of the PostgreSQL database"
  value       = lower("${var.app_name}-db")
}

output "postgres_server_firewall_allowed_start_ip_address" {
  description = "The start IP address for the PostgreSQL server firewall rule"
  value       = var.postgres_server_firewall_allowed_start_ip_address
}

output "postgres_server_firewall_allowed_end_ip_address" {
  description = "The end IP address for the PostgreSQL server firewall rule"
  value       = var.postgres_server_firewall_allowed_end_ip_address
}
