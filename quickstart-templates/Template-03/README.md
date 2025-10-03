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


---

## **Frontend and Backend Deployment Setup**: 
#### **Step 1: Set Up GitHub Secrets and Variables**

1. **Go to Your Frontend Repository:**
   - Navigate to Settings → Secrets and variables → Actions
   - Create the required **secrets** (3):
     - `SERVER_SSH_KEY` - Your .pem file content
     - `SERVER_HOST` - EC2 Elastic IP from Terraform output
     - `SERVER_USER` - `ubuntu`
   - Create the required **variables** (4):
     - `FRONTEND_PATH` - From Terraform output
     - `BACKEND_PATH` - From Terraform output
     - `DOCKER_COMPOSE_PATH` - From Terraform output
     - `FRONTEND_APP_ENV` - Your app environment variables

2. **Go to Your Backend Repository:**
   - Repeat the same process for backend repository
   - Use the same secret values but different variable values if needed



#### **Step 2: Clone Sample Code Repository**

📚 **Sample Code Repository Reference**

After setting up your GitHub secrets and variables, you'll need to clone sample code from the official repository:

**Repository**: [https://github.com/Promact-Ops/devops-docker-templates.git](https://github.com/Promact-Ops/devops-docker-templates.git)

**What's Available:**
- **Frontend Templates**: Next.js, Vite, React, Vue.js
- **Backend Templates**: Node.js, Python FastAPI, .NET, Java
- **Docker Compose Files**: Ready-to-use configurations (copied during infrastructure creation)
- **Sample Applications**: Complete working examples

**Repository Structure:**
```
sample-repos/
├── frontend/
│   ├── nextjs/          # Next.js application
│   ├── vite/            # Vite + React application
│   └── ...
├── backend/
│   ├── python-fastapi/  # Python FastAPI backend
│   ├── nodejs-express/  # Node.js Express backend
│   └── ...
└── docker-compose-templates/
    └── docker-compose-template-01.yml
```

> **💡 Pro Tip**: This repository contains production-ready templates that you can customize for your specific needs. The Docker Compose files are already configured to work with the infrastructure you just created.

> **⚠️ Important**: If you customize the deploy commands used in the `.github/workflows` files, first refer to the comments in the Docker Compose file: [docker-compose-template-01.yml](https://github.com/Promact-Ops/devops-docker-templates/blob/main/docker-compose-templates/docker-compose-template-01.yml)

**Clone the sample code repository:**
```bash
git clone https://github.com/Promact-Ops/devops-docker-templates.git
```

**Navigate to the sample repositories for frontend and backend frameworks. Select which framework you need for your project:**
```bash
cd devops-docker-templates/sample-repos
```

---

#### **Step 3: Set Up Frontend Repository**

**Navigate to your preferred frontend framework:**

**I have selected the Frontend Framework - Next.js:**
```bash
cd devops-docker-templates/sample-repos/frontend/nextjs  # Example: Next.js
```

**Copy Required Files to Your Repository:**

**1. Copy the Dockerfile:**
```bash
cp Dockerfile /path/to/your/frontend-repo/
```

**2. Copy the GitHub workflow file with exact directory structure:**
```bash
# Create the .github/workflows directory in your repository
mkdir -p /path/to/your/frontend-repo/.github/workflows

# Copy the workflow file
cp .github/workflows/template-03-frontend-deploy.yml /path/to/your/frontend-repo/.github/workflows/
```

**This ensures the exact same directory structure in your repository:**
```
your-frontend-repo/
├── .github/
│   └── workflows/
│       └── template-03-frontend-deploy.yml
├── Dockerfile
├── src/
└── ...
```

**Customize Your Configuration:**

**1. Workflow File (`template-03-frontend-deploy.yml`):**
   - **You can rename the file** to any name you prefer (e.g., `deploy.yml`, `ci-cd.yml`, `production-deploy.yml`)
   - **Open the file** and you'll see:
     ```yaml
     name: Frontend Deploy
     ```
     - Change the `name:` to whatever you want (e.g., "Frontend CI/CD Pipeline", "Production Deploy")
   
   - **Branch Configuration:**
     ```yaml
     on:
       workflow_dispatch:
       push:
         branches:
           - dev
     ```
     - **Update the branch name** (`dev`) to match your environment (e.g., `main`, `develop`, `staging`, `production`)
     - **When you push code** to the branch specified in this file, it will automatically trigger the pipeline



**2. Dockerfile:**
   - **This example is for Next.js projects** - for other frontend frameworks, check the actual Dockerfile in the sample repository for specific details
   - **For Next.js projects**, you can change the CMD value according to your `package.json` scripts:
     - `CMD ["npm", "start"]` - for production builds
     - `CMD ["npm", "run", "dev"]` - for development mode
     - `CMD ["node", "server.js"]` - if you have a custom server
   - **For other frameworks** check the Dockerfile in the sample repository to see the specific configuration and commands used
   - **Check your `package.json`** to see what scripts are available and choose the appropriate CMD

---

#### **Step 4: Set Up Backend Repository**

**Navigate to your preferred backend framework:**

**I have selected the Backend Framework - Express.js:**
```bash
cd devops-docker-templates/sample-repos/backend/nodejs-expressjs/  # Example: Express.js
```

**Copy Required Files to Your Repository:**

**1. Copy the Dockerfile:**
```bash
cp Dockerfile /path/to/your/backend-repo/
```

**2. Copy the GitHub workflow file with exact directory structure:**
```bash
# Create the .github/workflows directory in your repository
mkdir -p /path/to/your/backend-repo/.github/workflows

# Copy the workflow file
cp .github/workflows/template-03-backend-deploy.yml /path/to/your/backend-repo/.github/workflows/
```

**This ensures the exact same directory structure in your repository:**
```
your-backend-repo/
├── .github/
│   └── workflows/
│       └── template-03-backend-deploy.yml
├── Dockerfile
├── src/
└── ...
```

**Customize Your Configuration:**

**1. Workflow File (`template-03-backend-deploy.yml`):**
   - **You can rename the file** to any name you prefer (e.g., `deploy.yml`, `ci-cd.yml`, `production-deploy.yml`)
   - **Open the file** and you'll see:
     ```yaml
     name: Backend Deploy
     ```
     - Change the `name:` to whatever you want (e.g., "Backend CI/CD Pipeline", "Production Deploy")
   
   - **Branch Configuration:**
     ```yaml
     on:
       workflow_dispatch:
       push:
         branches:
           - dev
     ```
     - **Update the branch name** (`dev`) to match your environment (e.g., `main`, `develop`, `staging`, `production`)
     - **When you push code** to the branch specified in this file, it will automatically trigger the pipeline

**2. Dockerfile:**
   - **This example is for .NET projects** - for other backend frameworks (Node.js, Python, Java, etc.), check the actual Dockerfile in the sample repository for specific details
   - **For .NET projects**, you need to:
     - **Update the project file name** in your `.csproj` file (e.g., change `TestApi.csproj` to your actual project name)
     - **Update the ENTRYPOINT** to match your project:
       ```dockerfile
       ENTRYPOINT ["dotnet", "Your_Project_Name.dll"]
       ```
       - Replace `Your_Project_Name.dll` with your actual project DLL name
       - The DLL name should match your `.csproj` file name (without the .csproj extension)
     - **Example**: If your project is `UserManagement.csproj`, then use:
       ```dockerfile
       ENTRYPOINT ["dotnet", "UserManagement.dll"]
       ```
   - **For other frameworks** check the Dockerfile in the sample repository to see the specific configuration and commands used

---

#### **Step 5: Push All Changes To Your Frontend and Backend Repo**

**Before pushing your changes, follow these important cleanup steps:**

**1. Remove Terraform Generated Files:**
   ```bash
   # Remove the .terraform folder (generated by terraform init)
   rm -rf .terraform/
   
   # Remove .terraform.lock.hcl file if present
   rm -f .terraform.lock.hcl
   ```

**2. Remove Sensitive Configuration Files:**
   ```bash
   # Backup terraform.tfvars file on your local machine before removing (important for future updates - DO NOT PUSH TO REPO)
   cp terraform.tfvars ~/terraform.tfvars.backup
   
   # Remove terraform.tfvars file (contains sensitive information)
   rm -f terraform.tfvars
   ```

**3. Keep Important Infrastructure Files:**
   ```bash
   # DO NOT delete terraform.tfstate file - it contains all your infrastructure details
   # This file is essential for managing and updating your AWS resources
   # Keep it secure and backed up locally
   ```

> **💡 Backup Note**: The `terraform.tfvars.backup` file contains your project configuration and will be useful when you need to add/update any configuration in your cloud resources in the future.

**5. Push All Changes to Your Repositories:**

> **⚠️ Security Note**: Never commit sensitive files like `terraform.tfvars` or `.terraform/` folder to your repository. These contain sensitive information and should be kept secure locally.

> **💡 Pro Tip**: Keep a secure backup of your database credentials and other sensitive information from `terraform.tfvars` before removing the file.

---
#### **Step 6: Remove Cloned Repositories**

**Return to directory where we clone the repository and remove the devops-docker-templates repository:**
```bash
rm -rf devops-docker-templates
```

**Return to directory where we clone the repository and remove the devops-reusable-templates repository:**
```bash
rm -rf devops-reusable-templates
```

**Note**: 
- The SSH key we created is not deleted because it's stored in the `~/.ssh` directory.
- Your infrastructure code is now safely stored in your own repository's `Infrastructure` folder 

---

## 🎉 **Setup Complete!**

Congratulations! You've successfully:
- ✅ Deployed infrastructure
- ✅ Configured GitHub secrets and variables
- ✅ Deployed sample applications
- ✅ Set up CI/CD ready environment



## 🆘 **Need Help?**

If you encounter any issues:

1. **Check Prerequisites**: Ensure all requirements are met
2. **Contact DevOps Team**: Reach out for additional support
