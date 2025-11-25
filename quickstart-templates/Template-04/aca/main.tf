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



# ============================================
# Update Frontend App with Backend URL
# ============================================

# Update your existing frontend container app
resource "azurerm_container_app" "frontend_app" {
  name                         = "${var.project_name}-${var.environment}-aca-frontend-app"
  container_app_environment_id = var.azurerm_container_app_environment_id
  resource_group_name          = var.azurerm_resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.azurerm_user_assigned_identity_id]
  }


  registry {
    server   = var.azurerm_container_registry_login_server
    identity = var.azurerm_user_assigned_identity_id
  }

  template {
    min_replicas = var.frontend_aca_min_replicas
    max_replicas = var.frontend_aca_max_replicas


    custom_scale_rule {
      custom_rule_type = "cpu"
      name             = "cpu-scaling"
      metadata = {
        type  = "Utilization"
        value = var.frontend_scaling_cpu_threshold
      }
    }

    custom_scale_rule {
      name             = "memory-scaling"
      custom_rule_type = "memory"

      metadata = {
        type  = "Utilization"
        value = var.frontend_scaling_memory_threshold
      }
    }


    http_scale_rule {
      name                = "http-scaling"
      concurrent_requests = 1000 # Target concurrent requests per instance      
    }

    container {
      name   = "frontend"
      image  = var.frontend_container_image
      cpu    = var.frontend_cpu
      memory = var.frontend_memory

      # Existing environment variables
      env {
        name  = "POSTGRES_HOST"
        value = var.postgresql_fqdn
      }

      env {
        name  = "POSTGRES_PORT"
        value = "5432"
      }

      env {
        name  = "POSTGRES_DB"
        value = "postgres"
      }

      env {
        name  = "POSTGRES_USER"
        value = var.aca_identity_name
      }

      env {
        name  = "AUTH_METHOD"
        value = "entra_id"
      }

      env {
        name  = "AZURE_CLIENT_ID"
        value = var.aca_identity_name_client_id
      }

      # NEW: Backend API URL for internal communication
      env {
        name  = "BACKEND_API_URL"
        value = "http://${azurerm_container_app.backend_app.name}.internal.${var.azurerm_container_app_environment_aca_env_default_domain}"
      }

      # Alternative: Use FQDN directly Frontend (storage account)
      env {
        name  = "BACKEND_API_FQDN"
        value = azurerm_container_app.backend_app.ingress[0].fqdn
      }


      # ADD THESE NEW ENVIRONMENT VARIABLES
      env {
        name  = "STORAGE_ACCOUNT_NAME"
        value = var.storage_account_name
      }

      env {
        name  = "STORAGE_ACCOUNT_URL"
        value = var.storage_account_endpoint
      }

      env {
        name  = "STORAGE_CONTAINER_NAME"
        value = var.storage_account_container_name
      }


      liveness_probe {
        transport               = "HTTP"
        port                    = var.frontend_app_port
        path                    = "/health"
        initial_delay           = 10
        interval_seconds        = 30
        timeout                 = 5
        failure_count_threshold = 3
      }

      readiness_probe {
        transport               = "HTTP"
        port                    = var.frontend_app_port
        path                    = "/health"
        initial_delay           = 10
        interval_seconds        = 30
        timeout                 = 5
        failure_count_threshold = 3
      }
    }
  }

  ingress {
    external_enabled = true # Frontend is public
    target_port      = var.frontend_app_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [
    azurerm_container_app.backend_app # Ensure backend is created first
  ]
}





# ============================================
# Backend Container App (Internal Only)
# ============================================

resource "azurerm_container_app" "backend_app" {
  name                         = "${var.project_name}-${var.environment}-aca-backend-app"
  container_app_environment_id = var.azurerm_container_app_environment_id
  resource_group_name          = var.azurerm_resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.azurerm_user_assigned_identity_id]
  }


  registry {
    server   = var.azurerm_container_registry_login_server
    identity = var.azurerm_user_assigned_identity_id
  }


  template {
    min_replicas = var.backend_aca_min_replicas
    max_replicas = var.backend_aca_max_replicas



    custom_scale_rule {
      custom_rule_type = "cpu"
      name             = "cpu-scaling"
      metadata = {
        type  = "Utilization"
        value = var.backend_scaling_cpu_threshold
      }
    }

    custom_scale_rule {
      name             = "memory-scaling"
      custom_rule_type = "memory"

      metadata = {
        type  = "Utilization"
        value = var.backend_scaling_memory_threshold
      }
    }


    http_scale_rule {
      name                = "http-scaling"
      concurrent_requests = var.backend_scaling_http_requests_threshold
    }


    container {
      name   = "backend-api"
      image  = var.backend_container_image # Replace with your actual backend image
      cpu    = var.backend_cpu
      memory = var.backend_memory

      # Environment variables for backend
      env {
        name  = "POSTGRES_HOST"
        value = var.postgresql_fqdn
      }

      env {
        name  = "POSTGRES_PORT"
        value = "5432"
      }

      env {
        name  = "POSTGRES_DB"
        value = "postgres"
      }

      env {
        name  = "POSTGRES_USER"
        value = var.aca_identity_name
      }

      env {
        name  = "AUTH_METHOD"
        value = "entra_id"
      }

      env {
        name  = "AZURE_CLIENT_ID"
        value = var.aca_identity_name_client_id
      }

      env {
        name  = "ENVIRONMENT"
        value = "production"
      }

      # ADD THESE NEW ENVIRONMENT VARIABLES (storage account name)
      env {
        name  = "STORAGE_ACCOUNT_NAME"
        value = var.storage_account_name
      }

      env {
        name  = "STORAGE_ACCOUNT_URL"
        value = var.storage_account_endpoint
      }

      env {
        name  = "STORAGE_CONTAINER_NAME"
        value = var.storage_account_container_name
      }

      env {
        name  = "UPLOADS_CONTAINER_NAME"
        value = var.storage_account_uploads_container_name
      }

      # Health probes
      liveness_probe {
        transport               = "HTTP"
        port                    = var.backend_app_port
        path                    = "/health"
        initial_delay           = 10
        interval_seconds        = 30
        timeout                 = 5
        failure_count_threshold = 3
      }

      readiness_probe {
        transport               = "HTTP"
        port                    = var.backend_app_port
        path                    = "/ready"
        initial_delay           = 5
        interval_seconds        = 10
        timeout                 = 3
        failure_count_threshold = 3
      }
    }
  }

  # Internal ingress only (NOT exposed to internet)
  ingress {
    external_enabled = false # This makes it internal-only
    target_port      = var.backend_app_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }

  }

}




