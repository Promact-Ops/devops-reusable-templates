variable "subscribtion_id" {
    description = "The Subscription ID where resources will be created"
    type        = string
    
  
}

variable "location" {
    description = "The Azure region to deploy resources"
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


variable "azurerm_resource_group_name" {
    description = "The name of the resource group"
    type        = string
    
  
}

variable "azurerm_container_app_environment_id" {
  description = "The ID of the Azure Container App environment"
  type        = string
  

}

## identity variables
variable "azurerm_user_assigned_identity_id" {
    description = "The ID of the User Assigned Identity"
    type        = string
    
  
}

variable "azurerm_container_registry_login_server" {
  description = "The login server URL of the Azure Container Registry"
  type        = string
  
}

variable "aca_identity_name" {
    description = "Azure Container Registry Name"
    type        = string
    
}

variable "aca_identity_name_client_id" {
    description = "Azure Container Registry Name"
    type        = string
    

}

variable "storage_account_name"{
    description = "storage account name"
    type = string
    
}

variable "storage_account_endpoint"{
    description = "storage account endpoint"
    type = string
    
}

variable "storage_account_container_name"{
    description = "storage account container name"
    type = string
    
}

variable "storage_account_uploads_container_name"{
    description = "storage account uploads container name"
    type = string
    
}

variable "postgresql_fqdn" {
    description = "postgre sql fqdn"
    type = string
    
}

## frontend variables
variable "frontend_container_image" {
  description = "The container image for the frontend application"
  type        = string
}

variable "frontend_aca_min_replicas" {
    description = "The minimum number of replicas for the frontend Azure Container App"
    type        = number
    
}

variable "frontend_aca_max_replicas" {
    description = "The maximum number of replicas for the frontend Azure Container App"
    type        = number
    
}




variable "frontend_cpu" {
    description = "cpu frontend Azure Container App "
    type        = number
    
}

variable "frontend_memory" {
    description = "The memory threshold for scaling the frontend Azure Container App"
    type        = string
    
}


variable "frontend_scaling_cpu_threshold" {
    description = "The CPU threshold for scaling the frontend Azure Container App"
    type        = number
    
}

variable "frontend_scaling_memory_threshold" {
    description = "The memory threshold for scaling the frontend Azure Container App"
    type        = number
    
}

variable "frontend_scaling_http_requests_threshold" {
    description = "The http requests threshold for scaling the frontend Azure Container App"
    type        = number
    
}

variable "frontend_app_port" {
    description = "Frontend port Azure Container App"
    type        = number
    
}

variable "azurerm_container_app_environment_aca_env_default_domain"{
    description = "Frontend azurerm container app environment aca env default domain"
    type        = string

}



## backend variables
variable "backend_container_image" {
  description = "The container image for the backend application"
  type        = string
  
}




variable "backend_aca_min_replicas" {
    description = "The minimum number of replicas for the backend Azure Container App"
    type        = number
    
}

variable "backend_aca_max_replicas" {
    description = "The maximum number of replicas for the backend Azure Container App"
    type        = number
    
}



variable "backend_cpu" {
    description = "cpu backend Azure Container App "
    type        = number
    
}

variable "backend_memory" {
    description = "The memory threshold for scaling the backend Azure Container App"
    type        = string
    
}


variable "backend_scaling_cpu_threshold" {
    description = "The CPU threshold for scaling the backend Azure Container App"
    type        = number
    
}

variable "backend_scaling_memory_threshold" {
    description = "The memory threshold for scaling the backend Azure Container App"
    type        = number
    
}

variable "backend_scaling_http_requests_threshold" {
    description = "The http requests threshold for scaling the backend Azure Container App"
    type        = number
    
}


variable "backend_app_port" {
    description = "Backend port Azure Container App"
    type        = number
    
}