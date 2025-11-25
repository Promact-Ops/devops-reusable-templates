variable "subscribtion_id" {
  description = "The Subscription ID where resources will be created"
  type        = string


}

variable "tenant_id" {
  description = "The Tenant ID for the Azure Active Directory"
  type        = string

}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string


}

variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string


}

variable "project_name" {
  description = "The name of the project"
  type        = string


}

variable "environment" {
  description = "The deployment environment (e.g., Development, Staging, Production)"
  type        = string

}

variable "app_name" {
  description = "The name of the application"
  type        = string


}


## network variables
variable "azurerm_virtual_network_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)


}

variable "azurerm_subnet_aca_infra_subnet_cidr" {
  description = "The CIDR block for the ACA infrastructure subnet"
  type        = list(string)


}

variable "azurerm_subnet_aca_app_subnet_cidr" {
  description = "The CIDR block for the ACA application subnet"
  type        = list(string)


}

variable "azurerm_subnet_postgresql_private_endpoint_subnet_cidr" {
  description = "The CIDR block for the PostgreSQL private endpoint subnet"
  type        = list(string)


}

variable "azurerm_subnet_storage_private_endpoint_subnet_cidr" {
  description = "The CIDR block for the Storage Account private endpoint subnet"
  type        = list(string)


}



# Tags variable
variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)

}
