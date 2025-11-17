# Complete ACA deployment process

## Go to infra directory and follow this process

# Azure Container Apps Infrastructure with Terraform

A complete Terraform configuration for deploying a secure, production-ready Azure Container Apps environment with PostgreSQL, Storage Account, and Azure Container Registry.

## Architecture Overview

This infrastructure deploys:

- **Azure Container Apps Environment** with VNet integration
- **PostgreSQL Flexible Server** with Entra ID authentication and private endpoint
- **Azure Storage Account** with blob containers and private endpoint
- **Azure Container Registry** for container images
- **User-Assigned Managed Identity** for secure service authentication
- **Private DNS Zones** for secure name resolution
- **Log Analytics Workspace** for monitoring and diagnostics

All services are secured with private endpoints and communicate within a dedicated VNet.

---

## Prerequisites

- **Terraform** >= 1.0
- **Azure CLI** installed and authenticated
- **Azure Subscription** with appropriate permissions
- **Entra ID** (Azure AD) permissions for creating service principals

---

## Quick Start

### 1. Clone and Navigate

```bash
cd your-terraform-directory
```

### 2. Create terraform.tfvars

Create a `terraform.tfvars` file with your configuration:

#### NOTE : please go through the Azure networking existing configration and also go through the azure networking documentation to ensure no errors on deployment

```hcl
# Required Variables
subscribtion_id = "your-azure-subscription-id" # set it yours this just a example
resource_group_name = "your-resource-group-name" # set it yours this just a example
project_name    = "myapp" # set it yours this just a example
environment     = "prod" # set it yours this just a example
location        = "West US" # set it yours this just a example
app_name        = "my-application" # set it yours this just a example

# Network Configuration
azurerm_virtual_network_address_space                   = ["10.0.0.0/24"] # set it yours this just a example and will not works as it is
azurerm_subnet_aca_infra_subnet_cidr                   = ["10.0.0.0/24"] # set it yours this just a example and will not works as it is
azurerm_subnet_aca_app_subnet_cidr                     = ["10.0.0.0/24"] # set it yours this just a example and will not works as it is
azurerm_subnet_postgresql_private_endpoint_subnet_cidr = ["10.0.0.0/24"] # set it yours this just a example and will not works as it is
azurerm_subnet_storage_private_endpoint_subnet_cidr    = ["10.0.0.0/24"] # set it yours this just a example and will not works as it is

# Tags
tags = {
  Project     = "MyApplication" # set it yours this just a example 
  Environment = "Production" # set it yours this just a example 
  ManagedBy   = "Terraform" # set it yours this just a example 
}
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 4. Save Outputs

```bash
# Export important outputs
terraform output -json > outputs.json
```

---

## Configuration Variables

### Core Variables

| Variable | Type | Description | Required |
|----------|------|-------------|----------|
| `subscribtion_id` | string | Azure subscription ID | Yes |
| `location` | string | Azure region (e.g., "West US", "East US") | Yes |
| `project_name` | string | Project name prefix for resources | Yes |
| `environment` | string | Environment (dev, staging, prod) | Yes |
| `app_name` | string | Application name | Yes |

### Network Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `azurerm_virtual_network_address_space` | list(string) | VNet address space (sample) | `["10.0.0.0/24"]` |
| `azurerm_subnet_aca_infra_subnet_cidr` | list(string) | Container Apps infrastructure subnet (sample) | `["10.0.0.0/24"]` |
| `azurerm_subnet_aca_app_subnet_cidr` | list(string) | Container Apps application subne (sample) | `["10.0.0.0/24"]` |
| `azurerm_subnet_postgresql_private_endpoint_subnet_cidr` | list(string) | PostgreSQL private endpoint subnet (sample) | `["10.0.0.0/24"]` |
| `azurerm_subnet_storage_private_endpoint_subnet_cidr` | list(string) | Storage private endpoint subnet (sample) | `["10.0.0.0/24"]` |

### Tags Variable

| Variable | Type | Description |
|----------|------|-------------|
| `tags` | map(string) | Resource tags for organization |

---

## Resource Naming Convention

Resources follow this naming pattern:
```
{project_name}-{environment}-{resource_type}
```

Examples:
- Resource Group: `myapp-prod-rg`
- VNet: `myapp-prod-vnet`
- Container Apps Environment: `myapp-prod-aca-env`
- PostgreSQL Server: `myapp-prod-flexibleserver`

**Note:** Storage Account and ACR names include random suffixes for global uniqueness:
- Storage: `myappprodstorageabcd1234`
- ACR: `myappprodACRxyz789`

---

## Infrastructure Components

### 1. Networking

**Virtual Network**
- Dedicated VNet with customizable address space
- Multiple subnets for service isolation

**Subnets:**
- **ACA Infrastructure Subnet** - Container Apps control plane
- **ACA Application Subnet** - Container Apps workloads (delegated to Microsoft.App/environments)
- **PostgreSQL Private Endpoint Subnet** - Database private endpoint
- **Storage Private Endpoint Subnet** - Storage account private endpoint

### 2. Container Apps Environment

- Integrated with Log Analytics for monitoring
- Connected to infrastructure subnet for secure networking
- Ready for deploying containerized applications

### 3. PostgreSQL Flexible Server

**Configuration:**
- Version: PostgreSQL 16
- Authentication: Entra ID (Azure AD) only - password authentication disabled
- Network: Private endpoint only (no public access)
- Storage: 32 GB (P4 tier)
- SKU: B_Standard_B1ms (burstable)
- Admin: User-assigned managed identity as administrator

**Security Features:**
- Private DNS zone for name resolution
- VNet integration via private endpoint
- Entra ID authentication required

### 4. Azure Storage Account

**Features:**
- Account Tier: Standard
- Replication: LRS (Locally Redundant Storage)
- TLS: Minimum version 1.2
- Public Access: Disabled (private endpoint only)
- Blob Versioning: Enabled
- Soft Delete: 7 days retention

**Pre-created Containers:**
- `test-files` - Testing and validation
- `uploads` - User uploaded content
- `logs` - Application logs

**RBAC Permissions for Managed Identity:**
- Storage Blob Data Contributor
- Storage Account Contributor
- Storage Queue Data Contributor
- Storage Table Data Contributor

### 5. Azure Container Registry (ACR)

**Configuration:**
- SKU: Basic (upgradable to Standard/Premium)
- Admin Account: Disabled (using managed identity)
- Pull Permission: Granted to managed identity

### 6. Managed Identity

**User-Assigned Managed Identity** provides:
- Secure authentication to PostgreSQL (as admin)
- ACR image pull access
- Storage account full access (blob, queue, table)
- No credential management required

### 7. Private DNS Zones

**Configured Zones:**
- `privatelink.postgres.database.azure.com` - PostgreSQL
- `privatelink.blob.core.windows.net` - Storage Blobs

Both zones are linked to the VNet with automatic registration.

---

## Important Notes

### Tenant ID Configuration

The PostgreSQL configuration includes a hardcoded tenant ID:
```hcl
tenant_id = "6204282d-c27d-434a-82cb-330432f1de26"
```

**Action Required:** Update this with your actual Azure Tenant ID in `main.tf` (line 97) or make it a variable.

### Security Considerations

1. **No Default Values in Production**: Always use `terraform.tfvars` and never commit it to version control
2. **Subscription ID**: Treat as sensitive - use environment variables or secure secret management
3. **Network Planning**: Ensure CIDR blocks don't overlap with existing networks
4. **PostgreSQL Access**: Currently configured for managed identity only - no SQL authentication
5. **Firewall Rules**: Commented out in the code - uncomment if you need specific IP allowlisting

### Commented Resources

The following resources are commented out but available:
- PostgreSQL firewall rules (for IP allowlisting)
- User-based Entra ID admin (in addition to service principal admin)

---

## Outputs

After deployment, Terraform provides these outputs:

| Output | Description |
|--------|-------------|
| `aca_identity_client_id` | Client ID for the managed identity |
| `aca_identity_principal_id` | Principal ID for RBAC assignments |
| `aca_identity_name` | Name of the managed identity |
| `postgresql_flexible_server_fqdn` | PostgreSQL server connection string |
| `storage_account_name` | Storage account name |
| `storage_account_url` | Blob storage endpoint URL |
| `storage_containers` | List of created blob containers |
| `acr_login_server` | Container registry login URL |
| `acr_name` | Container registry name |

Access outputs:
```bash
terraform output
terraform output -json
terraform output aca_identity_client_id
```

---

## Usage Examples

### Connect to PostgreSQL

```bash
# Get the FQDN
POSTGRES_HOST=$(terraform output -raw postgresql_flexible_server_fqdn)

# Connect using Entra ID token
az login
psql "host=$POSTGRES_HOST port=5432 dbname=postgres sslmode=require user=<managed-identity-name>"
```

### Push Image to ACR

```bash
# Get ACR name
ACR_NAME=$(terraform output -raw acr_name)

# Login and push
az acr login --name $ACR_NAME
docker tag myapp:latest $ACR_NAME.azurecr.io/myapp:latest
docker push $ACR_NAME.azurecr.io/myapp:latest
```

### Access Storage with Managed Identity

```python
from azure.identity import ManagedIdentityCredential
from azure.storage.blob import BlobServiceClient

# Use in Container App with managed identity
credential = ManagedIdentityCredential(client_id="<identity_client_id>")
blob_service = BlobServiceClient(
    account_url="https://<storage-account>.blob.core.windows.net",
    credential=credential
)
```

---

## Maintenance

### Updating Infrastructure

```bash
# Modify terraform.tfvars or .tf files
terraform plan
terraform apply
```

### Destroying Infrastructure

```bash
terraform destroy
```

**Warning:** This will permanently delete all resources including databases and storage data.

---

## Troubleshooting

### Common Issues

**Issue:** Subnet delegation conflicts
- **Solution:** Ensure subnets are not already delegated to other services

**Issue:** PostgreSQL connection failures
- **Solution:** Verify private endpoint is provisioned and DNS resolution works from your VNet

**Issue:** Storage account name conflicts
- **Solution:** Random suffix should prevent this, but you can manually change project_name

**Issue:** Managed identity permissions
- **Solution:** Wait 2-3 minutes after deployment for RBAC propagation

### Validation

```bash
# Check state
terraform state list

# Validate configuration
terraform validate

# Check specific resource
terraform state show azurerm_postgresql_flexible_server.postgresql
```

---

## File Structure

```
.
├── main.tf                  # Core infrastructure (VNet, PostgreSQL, Container Apps)
├── variables.tf             # Variable declarations
├── storage-account.tf       # Storage account and private endpoint
├── acr.tf                   # Azure Container Registry
├── terraform.tfvars         # Your configuration values (DO NOT COMMIT)
└── README.md               # This documentation
```

---

## Best Practices

1. **Use separate tfvars files** for each environment (dev.tfvars, prod.tfvars)
2. **Store state remotely** using Azure Storage backend
3. **Enable state locking** to prevent concurrent modifications
4. **Use workspace isolation** for multiple environments
5. **Implement CI/CD** with proper approval gates for production
6. **Regular backups** of PostgreSQL and Storage Account
7. **Monitor costs** using Azure Cost Management

---

## Next Steps

1. Deploy Container Apps to the environment
2. Configure application-specific environment variables
3. Set up monitoring dashboards in Log Analytics
4. Implement backup strategies
5. Configure auto-scaling policies
6. Set up CI/CD pipelines

---

## Support

For issues related to:
- **Terraform**: [Terraform Documentation](https://www.terraform.io/docs)
- **Azure Provider**: [AzureRM Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- **Azure Services**: [Azure Documentation](https://docs.microsoft.com/azure)

---
---
---

# Go to aca directory and follow this steps

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
subscribtion_id = "your-subscription-id" # set it yours this just a example
location        = "West US" # set it yours this just a example

# Project Configuration
project_name = "myproject" # set it yours this just a example
environment  = "prod" # set it yours this just a example
app_name     = "myapp" # set it yours this just a example

# Resource Group
azurerm_resource_group_name = "myproject-prod-rg" # set it yours this just a example

# Container App Environment
azurerm_container_app_environment_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.App/managedEnvironments/YOUR_ENV"
azurerm_container_app_environment_aca_env_default_domain = "your-env-domain.azurecontainerapps.io" # set it yours this just a example

# Identity Configuration
azurerm_user_assigned_identity_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/YOUR_IDENTITY" # set it yours this just a example
aca_identity_name                 = "myproject-prod-aca-identity" # set it yours this just a example
aca_identity_name_client_id       = "your-identity-client-id" # set it yours this just a example

# Container Registry
azurerm_container_registry_login_server = "yourregistry.azurecr.io" # set it yours this just a example

# Storage Account
storage_account_name                      = "mystorageaccount" # set it yours this just a example
storage_account_endpoint                  = "https://mystorageaccount.blob.core.windows.net/" # set it yours this just a example
storage_account_container_name            = "app-files" # set it yours this just a example
storage_account_uploads_container_name    = "uploads" # set it yours this just a example

# PostgreSQL
postgresql_fqdn = "myproject-prod-flexibleserver.postgres.database.azure.com" # set it yours this just a example

# Frontend Configuration
frontend_container_image                    = "yourregistry.azurecr.io/frontend:latest" # set it yours this just a example
frontend_aca_min_replicas                   = 1 # set it yours this just a example
frontend_aca_max_replicas                   = 5 # set it yours this just a example
frontend_cpu                                = 0.5 # set it yours this just a example
frontend_memory                             = "1Gi" # set it yours this just a example
frontend_scaling_cpu_threshold              = 70 # set it yours this just a example
frontend_scaling_memory_threshold           = 70 # set it yours this just a example
frontend_scaling_http_requests_threshold    = 1000 # set it yours this just a example
frontend_app_port                           = 80 # set it yours this just a example

# Backend Configuration
backend_container_image                     = "yourregistry.azurecr.io/backend:latest" # set it yours this just a example
backend_aca_min_replicas                    = 1 # set it yours this just a example
backend_aca_max_replicas                    = 5 # set it yours this just a example
backend_cpu                                 = 0.5 # set it yours this just a example
backend_memory                              = "1Gi" # set it yours this just a example
backend_scaling_cpu_threshold               = 70 # set it yours this just a example
backend_scaling_memory_threshold            = 70 # set it yours this just a example
backend_scaling_http_requests_threshold     = 1000 # set it yours this just a example
backend_app_port                            = 8080 # set it yours this just a example
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

---
---



