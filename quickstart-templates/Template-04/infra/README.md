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

```hcl
# Required Variables
subscribtion_id = "your-azure-subscription-id"
project_name    = "myapp"
environment     = "prod"
location        = "West US"
app_name        = "my-application"

# Network Configuration
azurerm_virtual_network_address_space                   = ["10.10.0.0/16"]
azurerm_subnet_aca_infra_subnet_cidr                   = ["10.10.0.0/23"]
azurerm_subnet_aca_app_subnet_cidr                     = ["10.10.2.0/24"]
azurerm_subnet_postgresql_private_endpoint_subnet_cidr = ["10.10.3.0/28"]
azurerm_subnet_storage_private_endpoint_subnet_cidr    = ["10.10.4.0/28"]

# Tags
tags = {
  Project     = "MyApplication"
  Environment = "Production"
  ManagedBy   = "Terraform"
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
| `azurerm_virtual_network_address_space` | list(string) | VNet address space | `["10.10.0.0/16"]` |
| `azurerm_subnet_aca_infra_subnet_cidr` | list(string) | Container Apps infrastructure subnet | `["10.10.0.0/23"]` |
| `azurerm_subnet_aca_app_subnet_cidr` | list(string) | Container Apps application subnet | `["10.10.2.0/24"]` |
| `azurerm_subnet_postgresql_private_endpoint_subnet_cidr` | list(string) | PostgreSQL private endpoint subnet | `["10.10.3.0/28"]` |
| `azurerm_subnet_storage_private_endpoint_subnet_cidr` | list(string) | Storage private endpoint subnet | `["10.10.4.0/28"]` |

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

