# Template 03 - Deploy Frontend and Backend to Azure VM, Managed DB, Storage Account

This template creates a complete, development-ready Azure infrastructure along with a CI/CD pipeline, seamlessly integrating with your existing frontend and backend repositories.

**The following Azure services will be created using this template:**

| Service                        | Purpose               | Details                                                  |
| ------------------------------ | --------------------- | -------------------------------------------------------- |
| **Resource Group**             | Resource organization | Container for all Azure resources                        |
| **Virtual Network**            | Network isolation     | Public subnet, security groups, route tables             |
| **Virtual Machine**            | Application hosting   | Ubuntu with Docker pre-installed                         |
| **Storage Account**            | File storage          | Encrypted, versioned, with public and private containers |
| **PostgreSQL Flexible Server** | Database              | PostgreSQL with automated backups and monitoring         |
| **Public IP**                  | External access       | Static IP for VM connectivity                            |
| **Network Security Group**     | Network security      | Port 22 (SSH), 80 (HTTP), 443 (HTTPS) access             |

### Prerequisites

Before starting, ensure you have all the required software and configurations installed.

**Repository Requirements**: Ensure your existing frontend and backend repositories are already cloned locally for Infrastructure and CI/CD setup.

This includes:

- Azure account with an active subscription
- Basic Git knowledge and command line experience
- Azure CLI installed and configured (login to Azure CLI or ask DevOps team for details)
- Terraform CLI installed and working
- Service Principal or App Registration with Contributor access over subscription (ask DevOps team for subscription and Service Principal details)

---

## Quick Start Guide

This guide will walk you through setting up your environment and deploying your applications to Azure infrastructure.

**Pro Tip**: Each step builds on the previous one. Follow the process in order for the best experience.

### Step 1: Create SSH Key Pair (Required)

Before deploying the template, you need to create an SSH key pair as the public key is required in the terraform.tfvars file for VM access.

**Create SSH Key Pair:**

**For Windows (using PowerShell or Command Prompt):**

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure-vm-key
```

**For Linux/macOS:**

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure-vm-key
```

**What this command does:**

1. Creates an RSA key pair with 4096-bit encryption
2. Saves the private key as `azure-vm-key` in your ~/.ssh/ directory
3. Saves the public key as `azure-vm-key.pub` in your ~/.ssh/ directory
4. Sets proper permissions automatically

**Get your public key content:**

**For Windows:**

```bash
type %USERPROFILE%\.ssh\azure-vm-key.pub
```

**For Linux/macOS:**

```bash
cat ~/.ssh/azure-vm-key.pub
```

**Important Notes:**

- Copy the entire public key content (starts with ssh-rsa and ends with your email/username)
- You'll need to paste this public key content in the terraform.tfvars file
- Keep your private key secure (never share it)
- The private key will be used to SSH into your Azure VM

### Step 2: Create Azure Infrastructure Using Terraform

**Start Terraform Deployment**

Ensure you have completed the Azure CLI setup from the Prerequisites section before proceeding with this step.

1. **Clone the Repository:**

   **Using HTTPS:**

   ```bash
   git clone https://github.com/Promact-Ops/devops-reusable-templates.git
   ```

   **Using SSH (if you have SSH keys configured):**

   ```bash
   git clone git@github.com:Promact-Ops/devops-reusable-templates.git
   ```

2. **Copy Terraform Files to Your Repository:**

   **Navigate to the Terraform directory:**

   ```bash
   cd devops-reusable-templates/quickstart-templates/Template-03/IAC/terraform
   ```

   **Copy the Terraform files to your existing backend/frontend repository:**

   - Create an `Infrastructure` folder in your repository
   - Copy all files from the terraform directory to your repository's `Infrastructure` folder
   - This ensures you have the infrastructure code in your own repository for version control
   - **Benefits**: Your infrastructure code stays with your application code, making it easier to manage changes and track infrastructure evolution

   **Example structure in your repository:**

   ```
   your-repo/
   ├── Infrastructure/
   │   ├── main.tf
   │   ├── variables.tf
   │   ├── outputs.tf
   │   ├── terraform.tfvars.example
   │   ├── versions.tf
   │   ├── vm-startup-script.sh
   │   └── ...
   ├── src/
   ├── README.md
   └── ...
   ```

3. **Configure Variables:**

   **Navigate to your repository's Infrastructure folder:**

   ```bash
   cd /path/to/your/repo/Infrastructure
   ```

   **Copy the example variables file:**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

**Terraform Variables Configuration**

**Edit terraform.tfvars with your project details:**

**Copy the terraform.tfvars.example content and paste it into terraform.tfvars:**

```bash
# Define all the values for the variables in this file

##################################################
# Required for authentication to Azure
##################################################
# This is the subscription ID, can be found in subscriptions in azure portal or ask devops team
subscription_id = "your-subscription-id"

# This is the client ID, can be found in app registration in azure portal
client_id = "your-client-id"

# This is the client secret, can be found in Client credentials of app registration in azure portal
client_secret = "your-client-secret"

# This is the tenant ID, can be found in directory ID of the tenant in app registration in azure portal
tenant_id = "your-tenant-id"

##################################################
# Common variables
##################################################
# this would be used for naming all the resources, give a short name for the application, no special characters, no spaces, no uppercase, no numbers, no hyphens, no dashes
app_name = "myapp"

# all the resources will be created in this location/region, checkout this doc for more supported locations - https://learn.microsoft.com/en-us/azure/reliability/regions-list
location = "eastus"

##################################################
# These tags will be applied to all the resources
##################################################
tags = {
  Company     = "Promact"
  CreatedBy   = "saquib"
  Project     = "promact-reusability-initiative"
  Environment = "dev"
  # Do not add new properties here, if you need to add new properties, ask devops team first
}

##################################################
# For Virtual Network
##################################################
# CIDR block for Virtual Network, it should be unique and not overlapping with any other VNet in the same subscription, it must be in format x.x.x.x/16, example - "10.0.0.0/16, 10.1.0.0/16, 10.2.0.0/16, ..... 10.255.0.0/16"
vnet_cidr = "10.20.0.0/16"

##################################################
# For Virtual Machine
##################################################
# Syntax - "sku_tiername", for example - "Standard_B1s" (B series, 1 vCPUs, 1 GB RAM), "Standard_1ms" (B series, 1 vCPUs, 2 GB RAM), "Standard_B2s" (B series, 2 vCPUs, 4 GB RAM), "Standard_B4s" (B series, 4 vCPUs, 16 GB RAM), "Standard_B8s" (B series, 8 vCPUs, 16 GB RAM), "Standard_B16s" (B series, 16 vCPUs, 32 GB RAM), "Standard_B32s" (B series, 32 vCPUs, 64 GB RAM), "Standard_B64s" (B series, 64 vCPUs, 128 GB RAM).
# For more details, checkout this doc - https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview
vm_size = "Standard_B2s"

# When you created an ssh key pair, you will get a private and public key, you need to use the public key here, paste the full public key, NOT the path
ssh_public_key = "your-public-key"

# This is the version of the VM image, you can check the latest version from this doc - https://learn.microsoft.com/en-us/azure/virtual-machines/linux/endorsed-distros
# ONLY linux vms can be created using this template, windows vms are not supported
vm_image_version = "ubuntu-24_04-lts"

##################################################
# For PostgreSQL server
##################################################
# This is the version of the PostgreSQL server, you can check the latest version from this doc - https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-supported-versions
# ONLY postgresql server can be created using this template, other databases are not supported, always use the latest version supported by azure
# Dont use in preview versions of the database, at the time of writing this, the latest version is 17
postgres_version = "17"

# The name of the SKU, follows the tier + name pattern (e.g. B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)
# For more details, checkout this doc - https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute
# eg - "B1ms" (B series, 1 vCPUs, 1 GB RAM), "B2ms" (B series, 2 vCPUs, 4 GB RAM)
postgres_sku_name = "B_Standard_B1ms"

# The storage performance tier for the PostgreSQL server, related to IOPS
# Possible values are P4, P6, P10, P15,P20, P30,P40, P50,P60, P70 or P80
# Pick atleast P10 for decent performance
postgres_storage_tier = "P10"

# The storage size for the PostgreSQL server in MB, it must be in the range of 1024.
# Check this out for more details - https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-storage
# Minimum starting from 32768 MB
postgres_storage_mb = 32768

# The firewall rule for the PostgreSQL server
# To allow only your ip then set both the start and end ip address to your ip address -> example - "122.122.122.122"
# If you want to allow all ips (not recommended for production) then set start and end ip address to "0.0.0.0" and "255.255.255.255" respectively.
# For adding more ip addresses, go to azure portal and add the ip addresses to the firewall rule in postgresql server network settings.

# The start IP address for the PostgreSQL server firewall rule
postgres_server_firewall_allowed_start_ip_address = "0.0.0.0"

# The end IP address for the PostgreSQL server firewall rule
postgres_server_firewall_allowed_end_ip_address = "255.255.255.255"
```

4. **Terraform Commands:**  
   Note: Run these commands in the directory where tf files are present    
   **Initialize Terraform:**

   ```bash
   terraform init
   ```

   This command initializes the Terraform working directory and downloads the required providers.

   **Validate Configuration:**

   ```bash
   terraform validate
   ```

   This command validates the Terraform configuration files for syntax errors and consistency.

   **Review the deployment plan:**

   ```bash
   terraform plan
   ```

   This command creates an execution plan showing what actions Terraform will take to create your infrastructure.

   **Deploy the infrastructure:**

   ```bash
   terraform apply
   ```

   This command applies the changes required to reach the desired state of the configuration. You'll be prompted to confirm before proceeding.

   **Note**: This will ask for your approval to create the infrastructure. Enter **yes** to proceed.

   **Destroy the infrastructure (when needed):**

   ```bash
   terraform destroy
   ```

   This command destroys all the resources created by Terraform. Use this when you want to clean up your infrastructure.

5. **Save the Output:**

   **Get the complete setup information:**

   ```bash
   terraform output
   ```

   This will display all the output values including:

   - VM public IP address
   - Storage account details
   - PostgreSQL server connection information
   - Resource group information

## What Happens Next?

After successfully deploying your infrastructure with Terraform:

1. **Save the Output**: Run `terraform output` to get all the infrastructure details like public IP, storage account name, database endpoint, etc.
2. **Connection Details**: Use the outputs to configure your applications and CI/CD pipelines
3. **VM Access**: Your Azure VM will be ready with Docker installed and accessible via SSH
4. **Database Access**: PostgreSQL server will be configured and ready for connections
5. **Storage Access**: Storage account with public and private containers will be available

**Key Outputs You'll Need:**

- **VM Public IP**: For server access and deployment
- **Storage Account Details**: For file storage and CDN configuration
- **PostgreSQL Connection Details**: For database connections
- **Resource Group Information**: For Azure portal navigation

**Frontend and Backend Deployment Setup**: Coming soon - detailed guides for setting up CI/CD pipelines and deploying your applications will be updated soon.

---
