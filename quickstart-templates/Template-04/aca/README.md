# Azure Container Apps Terraform Configuration

## Overview

This Terraform configuration deploys a complete Azure Container Apps infrastructure with a frontend and backend application, including auto-scaling, health monitoring, and integration with Azure services (PostgreSQL, Storage Account, Container Registry).


## Prerequisites

- **Terraform**: v1.0 or higher
- **Azure CLI**: Authenticated with appropriate permissions
- **Azure Resources** (must exist before running):
  - Resource Group
  - Container App Environment
  - User Assigned Identity
  - Container Registry
  - PostgreSQL Flexible Server
  - Storage Account with containers

## Quick Start

### 1. Clone or Download Configuration Files

Ensure you have these files:
- `main.tf` - Infrastructure definition
- `variables.tf` - Variable declarations
- `terraform.tfvars` - Your environment-specific values

### 2. Create `terraform.tfvars`

Create a `terraform.tfvars` file with your specific values:

```hcl
# Azure Configuration
subscribtion_id = "your-subscription-id"
location        = "West US"

# Project Configuration
project_name = "myproject"
environment  = "prod"
app_name     = "myapp"

# Resource Group
azurerm_resource_group_name = "myproject-prod-rg"

# Container App Environment
azurerm_container_app_environment_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.App/managedEnvironments/YOUR_ENV"
azurerm_container_app_environment_aca_env_default_domain = "your-env-domain.azurecontainerapps.io"

# Identity Configuration
azurerm_user_assigned_identity_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/YOUR_IDENTITY"
aca_identity_name                 = "myproject-prod-aca-identity"
aca_identity_name_client_id       = "your-identity-client-id"

# Container Registry
azurerm_container_registry_login_server = "yourregistry.azurecr.io"

# Storage Account
storage_account_name                      = "mystorageaccount"
storage_account_endpoint                  = "https://mystorageaccount.blob.core.windows.net/"
storage_account_container_name            = "app-files"
storage_account_uploads_container_name    = "uploads"

# PostgreSQL
postgresql_fqdn = "myproject-prod-flexibleserver.postgres.database.azure.com"

# Frontend Configuration
frontend_container_image                    = "yourregistry.azurecr.io/frontend:latest"
frontend_aca_min_replicas                   = 1
frontend_aca_max_replicas                   = 5
frontend_cpu                                = 0.5
frontend_memory                             = "1Gi"
frontend_scaling_cpu_threshold              = 70
frontend_scaling_memory_threshold           = 70
frontend_scaling_http_requests_threshold    = 1000
frontend_app_port                           = 80

# Backend Configuration
backend_container_image                     = "yourregistry.azurecr.io/backend:latest"
backend_aca_min_replicas                    = 1
backend_aca_max_replicas                    = 5
backend_cpu                                 = 0.5
backend_memory                              = "1Gi"
backend_scaling_cpu_threshold               = 70
backend_scaling_memory_threshold            = 70
backend_scaling_http_requests_threshold     = 1000
backend_app_port                            = 8080
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review Deployment Plan

```bash
terraform plan
```

### 5. Deploy Infrastructure

```bash
terraform apply
```

### 6. Get Frontend URL

```bash
terraform output frontend_fqdn
```

## Configuration Details

### Frontend Container App

**Features:**
- **Public Access**: Externally accessible via HTTPS
- **Auto-scaling**: Scales between 1-3 replicas (configurable)
- **Health Monitoring**: Liveness and readiness probes on `/health`
- **Managed Identity**: Uses Azure AD for authentication

**Scaling Triggers:**
- CPU utilization > 70%
- Memory utilization > 70%
- HTTP concurrent requests > 1000

**Environment Variables:**
- PostgreSQL connection details
- Backend API URLs (internal and FQDN)
- Storage account configuration
- Azure identity settings

### Backend Container App

**Features:**
- **Internal Only**: Not exposed to the internet
- **Auto-scaling**: Scales between 1-3 replicas (configurable)
- **Health Monitoring**: Separate liveness (`/health`) and readiness (`/ready`) probes
- **Managed Identity**: Uses Azure AD for authentication

**Scaling Triggers:**
- CPU utilization > 70%
- Memory utilization > 70%
- HTTP concurrent requests > 1000

**Environment Variables:**
- PostgreSQL connection details
- Storage account configuration (including uploads container)
- Azure identity settings
- Environment identifier

## Variable Reference

### Required Variables (No Defaults)

After removing defaults from `variables.tf`, you must provide these in `terraform.tfvars`:

| Variable | Type | Description |
|----------|------|-------------|
| `subscribtion_id` | string | Azure Subscription ID |
| `location` | string | Azure region (e.g., "West US") |
| `project_name` | string | Project name for resource naming |
| `environment` | string | Environment (dev/staging/prod) |
| `azurerm_resource_group_name` | string | Resource group name |
| `azurerm_container_app_environment_id` | string | Container App Environment resource ID |
| `azurerm_user_assigned_identity_id` | string | User Assigned Identity resource ID |
| `aca_identity_name` | string | Identity name |
| `aca_identity_name_client_id` | string | Identity client ID |
| `azurerm_container_registry_login_server` | string | ACR login server URL |
| `storage_account_name` | string | Storage account name |
| `storage_account_endpoint` | string | Storage account blob endpoint |
| `storage_account_container_name` | string | Main storage container name |
| `storage_account_uploads_container_name` | string | Uploads container name |
| `postgresql_fqdn` | string | PostgreSQL FQDN |
| `frontend_container_image` | string | Frontend container image |
| `backend_container_image` | string | Backend container image |

### Optional Variables (Can Use Defaults or Override)

| Variable | Default | Description |
|----------|---------|-------------|
| `frontend_aca_min_replicas` | 1 | Minimum frontend replicas |
| `frontend_aca_max_replicas` | 3 | Maximum frontend replicas |
| `frontend_cpu` | 0.5 | Frontend CPU allocation |
| `frontend_memory` | "1Gi" | Frontend memory allocation |
| `frontend_app_port` | 80 | Frontend application port |
| `backend_aca_min_replicas` | 1 | Minimum backend replicas |
| `backend_aca_max_replicas` | 3 | Maximum backend replicas |
| `backend_cpu` | 0.5 | Backend CPU allocation |
| `backend_memory` | "1Gi" | Backend memory allocation |
| `backend_app_port` | 8080 | Backend application port |
| `*_scaling_cpu_threshold` | 70 | CPU scaling threshold (%) |
| `*_scaling_memory_threshold` | 70 | Memory scaling threshold (%) |
| `*_scaling_http_requests_threshold` | 1000 | HTTP requests threshold |

## Resource Naming Convention

Resources follow this naming pattern:
```
{project_name}-{environment}-{resource_type}
```

**Examples:**
- Frontend: `myproject-prod-aca-frontend-app`
- Backend: `myproject-prod-aca-backend-app`

## Security Considerations

1. **Managed Identity**: Both apps use User Assigned Managed Identity for Azure service authentication
2. **Internal Backend**: Backend is not exposed to the internet
3. **PostgreSQL Authentication**: Uses Azure AD (Entra ID) authentication
4. **Container Registry**: Private registry with managed identity access
5. **No Hardcoded Secrets**: All sensitive values should be in `terraform.tfvars` (excluded from version control)

## Networking

- **Frontend**: Public ingress, accessible from internet
- **Backend**: Internal ingress only, accessible within Container App Environment
- **Communication**: Frontend communicates with backend via internal DNS
  - Internal URL: `http://{backend-app-name}.internal.{env-domain}`
  - FQDN: Dynamically generated and passed to frontend

## Health Checks

### Frontend
- **Liveness**: HTTP probe on `/health` (port 80)
- **Readiness**: HTTP probe on `/health` (port 80)

### Backend
- **Liveness**: HTTP probe on `/health` (port 8080)
- **Readiness**: HTTP probe on `/ready` (port 8080)

**Configuration:**
- Initial delay: 10 seconds (liveness), 5 seconds (readiness)
- Interval: 30 seconds (liveness), 10 seconds (readiness)
- Timeout: 5 seconds (liveness), 3 seconds (readiness)
- Failure threshold: 3 consecutive failures

## Outputs

| Output | Description |
|--------|-------------|
| `frontend_fqdn` | Frontend application FQDN and ingress details |

## Maintenance

### Updating Container Images

1. Update image tags in `terraform.tfvars`:
   ```hcl
   frontend_container_image = "yourregistry.azurecr.io/frontend:v2.0"
   backend_container_image  = "yourregistry.azurecr.io/backend:v2.0"
   ```

2. Apply changes:
   ```bash
   terraform apply
   ```

### Scaling Adjustments

Modify replica counts or scaling thresholds in `terraform.tfvars`:
```hcl
frontend_aca_max_replicas = 10
frontend_scaling_cpu_threshold = 60
```

### Updating Resources

For changes to resource IDs (environment, identity, etc.), update `terraform.tfvars` and run:
```bash
terraform plan
terraform apply
```

## Troubleshooting

### Common Issues

**Issue**: Container fails to start
- Check container logs in Azure Portal
- Verify image exists in Container Registry
- Ensure managed identity has ACR pull permissions

**Issue**: Backend unreachable from frontend
- Verify backend ingress is set to `external_enabled = false`
- Check Container App Environment networking
- Confirm environment domain is correct

**Issue**: PostgreSQL connection failures
- Verify managed identity has database permissions
- Check PostgreSQL firewall rules allow Container Apps
- Ensure FQDN and authentication settings are correct

**Issue**: Storage access denied
- Verify managed identity has Storage Blob Data Contributor role
- Check storage account firewall settings
- Confirm container names match

## Best Practices

1. **Version Control**: Keep `terraform.tfvars` in `.gitignore`
2. **State Management**: Use remote backend (Azure Storage) for production
3. **Environment Separation**: Use separate tfvars files per environment
4. **Image Tags**: Use specific version tags, avoid `latest`
5. **Resource Locks**: Apply locks to prevent accidental deletion
6. **Monitoring**: Enable Application Insights for both apps
7. **Backup**: Regular backups of Terraform state

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

⚠️ **Warning**: This will delete the Container Apps but NOT the dependent resources (Resource Group, Storage, Database, etc.)

## Additional Resources

- [Azure Container Apps Documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Managed Identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)

## Support

For issues or questions:
1. Check Azure Container Apps logs in Azure Portal
2. Review Terraform plan output for configuration issues
3. Verify all prerequisite resources exist and are accessible
4. Ensure managed identity has required permissions

