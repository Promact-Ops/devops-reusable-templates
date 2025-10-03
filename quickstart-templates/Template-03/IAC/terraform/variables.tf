# REQUIRED VARIABLES FOR AZURE INFRASTRUCTURE


# Required for authentication to Azure
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  nullable    = false
}

variable "client_id" {
  description = "Azure client ID"
  type        = string
  nullable    = false
}

variable "client_secret" {
  description = "Azure client secret"
  type        = string
  nullable    = false
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
  nullable    = false
}

########################################################################################
# Common variables
variable "app_name" {
  description = "Short name for the application"
  type        = string
  nullable    = false
}

variable "location" {
  description = "Azure resource location"
  type        = string
  default     = "eastus"
  nullable    = false
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default = {
    Company     = "Promact"
    CreatedBy   = "terraform"
    Project     = "reusable-template"
    Environment = "dev"
  }
}

########################################################################################
# For Virtual Network
variable "vnet_cidr" {
  description = "CIDR block for Virtual Network. It must be in the format x.x.x.x/16"
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+/16$", var.vnet_cidr))
    error_message = "The VNet CIDR block must be in the format x.x.x.x/16 (e.g., 10.1.0.0/16)."
  }
}

########################################################################################
# For Virtual Machine
variable "vm_size" {
  description = "Size of the VM"
  type        = string
  nullable    = false
}

variable "ssh_public_key" {
  description = "Your public key for SSH access"
  type        = string
  nullable    = false
}

variable "vm_image_version" {
  description = "Version of the VM image"
  type        = string
  nullable    = false
}

########################################################################################
# For PostgreSQL server
variable "postgres_version" {
  description = "Version of the PostgreSQL server"
  type        = string
  nullable    = false
}

variable "postgres_sku_name" {
  description = "SKU name for the PostgreSQL server"
  type        = string
  nullable    = false
}

variable "postgres_storage_tier" {
  description = "Storage tier for the PostgreSQL server"
  type        = string
  nullable    = false
}

variable "postgres_storage_mb" {
  description = "Storage size for the PostgreSQL server"
  type        = number
  nullable    = false
}

variable "postgres_server_firewall_allowed_start_ip_address" {
  description = "Start IP address for the PostgreSQL server firewall rule"
  type        = string
  nullable    = false
}

variable "postgres_server_firewall_allowed_end_ip_address" {
  description = "End IP address for the PostgreSQL server firewall rule"
  type        = string
  nullable    = false
}
