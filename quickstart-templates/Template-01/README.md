# 🚀 Template 01 - Deploy Frontend and Backend to AWS EC2, RDS, S3

## 🏗️ **Infrastructure Overview**

This template creates a complete, production-ready AWS infrastructure:

### **Cloud Services Created**
| Service | Purpose | Details |
|---------|---------|---------|
| **VPC** | Network isolation | Public/private subnets, security groups, route tables |
| **EC2** | Application hosting | Ubuntu with Docker pre-installed |
| **S3** | File storage | Encrypted, versioned, IAM-controlled access |
| **RDS** | Database | PostgreSQL with automated backups and monitoring |
| **IAM** | Security | Role-based access control for EC2-S3 communication |
| **Security Groups** | Network security | Port 22 (SSH), 80 (HTTP), 8080 (Backend) access |

## 📋 **Prerequisites**

Before starting, ensure you have all the required software and configurations installed. 

**📖 [Complete Prerequisites Guide](../../prerequisites/README.md)**

**📋 Repository Requirements**: Ensure your existing frontend and backend repositories are already cloned locally for Infrastructure and CI/CD setup. 

This includes:
- ✅ **GitHub Account** with repository creation access
- ✅ **AWS Account** with administrator access  
- ✅ **Basic Git knowledge** and command line experience
- ✅ **AWS CLI** installed and configured
- ✅ **Terraform CLI** installed and working

> **🔑 AWS Access Required**: You'll need AWS access key ID and secret access key to configure AWS CLI. These are created in the AWS IAM console.


---

## 🚀 **Quick Start Guide**

This guide will walk you through setting up your development environment and deploying your applications to AWS infrastructure.

> **💡 Pro Tip**: Each step builds on the previous one. Follow the process in order for the best experience.





## 🛠️ Setup Instructions

---

### 📍 **Step 1: Create AWS Infrastructure Using Terraform**

> **📖 Detailed Guide**: Clone the repository first to get the Terraform configuration files, then copy them to your own repository's Infrastructure folder

#### **A. AWS CLI Configuration**

> **📖 AWS CLI Configuration is covered in the [Prerequisites Guide](../../../prerequisites/README.md#%EF%B8%8F-aws-cli-configuration)**

Ensure you have completed the AWS CLI setup before proceeding with this step.

#### **B. Create EC2 SSH Key Pair (Required)**

**Create, Configure, and Verify SSH Key Pair (Single Command):**

**Replace "my-ec2-key" with your preferred key name**

**Note**: The SSH_KEY_NAME variable is only used for this step - it won't persist in your shell
```bash
SSH_KEY_NAME="my-ec2-key" && \
aws ec2 create-key-pair --key-name "$SSH_KEY_NAME" --query 'KeyMaterial' --output text > ~/.ssh/$SSH_KEY_NAME.pem && \
chmod 400 ~/.ssh/$SSH_KEY_NAME.pem && \
aws ec2 describe-key-pairs --key-names "$SSH_KEY_NAME" && \
ls -la ~/.ssh/$SSH_KEY_NAME.pem && \
echo "✅ SSH Key '$SSH_KEY_NAME' created successfully!" && \
echo "🔑 Use this key name in terraform.tfvars: ec2_key_name = \"$SSH_KEY_NAME\""
```

**What this command does:**
1. Sets your key name variable.
2. Creates the SSH key pair in AWS
3. Downloads the private key to ~/.ssh/
4. Sets proper permissions (400)
5. Verifies the key exists in AWS
6. Shows the local file details
7. Prints success message
8. Shows exactly what to put in terraform.tfvars

> **⚠️ Important**: 
> - **Key Name**: You can use any name you prefer (e.g., "my-project-key", "dev-server-key", "production-key")
> - **File Naming**: The downloaded file should match your key name for consistency
> - **Terraform Variable**: Update `ec2_key_name` in `terraform.tfvars` with your chosen key name
> - Keep your private key secure (never share it)
> - The key will be used to SSH into your EC2 instance

#### **C. Start Terraform Deployment**

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
   cd devops-reusable-templates/quickstart-templates/Template-01/IaC/terraform
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

   **Edit terraform.tfvars with your project details:**
   Update: `project_name`, `environment`, `ec2_key_name` (which we created in earlier steps), etc.
   ```bash
   vim terraform.tfvars
   ```

4. **Initialize and Deploy:**

   **Initialize Terraform:**
   ```bash
   terraform init
   ```

   **Review the deployment plan:**
   ```bash
   terraform plan
   ```

   **Deploy the infrastructure:**
   ```bash
   terraform apply
   ```

   **Note**: This will ask for your approval to create the infrastructure. Enter **yes** to proceed.

5. **Save the Output:**

   **Get the complete setup guide:**
   ```bash
   terraform output github_secrets_setup_guide
   ```



## 🔄 **What Happens Next?**

After successfully deploying your infrastructure with Terraform:

1. **Save the Output**: Run `terraform output github_secrets_setup_guide` to get the complete setup guide
2. **Continue to Step 2**: Create GitHub Repositories
3. **Prepare for Deployment**: Your EC2 instance will be ready with Docker installed
4. **Get Connection Details**: Use the outputs to configure your GitHub repositories

### **Key Outputs You'll Need:**
- **EC2 Elastic IP**: For `SERVER_HOST` secret
- **Project Paths**: For GitHub variables
- **S3 Bucket Details**: For application configuration
- **RDS Endpoint**: For database connections

---
### 📍 **Step 2: Set Up GitHub Secrets and Variables**

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

---

## 📚 **Sample Code Repository Reference**

After setting up your GitHub secrets and variables, you'll need to clone sample code from the official repository:

**Repository**: [https://github.com/Promact-Ops/devops-docker-templates.git](https://github.com/Promact-Ops/devops-docker-templates.git)

**What's Available:**
- **Frontend Templates**: Next.js, Vite, React, Vue.js
- **Backend Templates**: Node.js, Python FastAPI, .NET, Java
- **Docker Compose Files**: Ready-to-use configurations
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
    └── docker-compose-Template-01.yml
```

> **💡 Pro Tip**: This repository contains production-ready templates that you can customize for your specific needs. The Docker Compose files are already configured to work with the infrastructure you just created.

---

### 📍 **Step 3: Clone Sample Code Repository**

**Clone the sample code repository:**
```bash
git clone https://github.com/Promact-Ops/devops-docker-templates.git
```

**Navigate to the sample repositories for frontend and backend frameworks. Select which framework you need for your project:**
```bash
cd devops-docker-templates/sample-repos
```

---

### 📍 **Step 4: Set Up Frontend Repository**

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
cp .github/workflows/template-01-frontend-deploy.yml /path/to/your/frontend-repo/.github/workflows/
```

**This ensures the exact same directory structure in your repository:**
```
your-frontend-repo/
├── .github/
│   └── workflows/
│       └── template-01-frontend-deploy.yml
├── Dockerfile
├── src/
└── ...
```

**Customize Your Configuration:**

**1. Workflow File (`template-01-frontend-deploy.yml`):**
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

### 📍 **Step 5: Set Up Backend Repository**

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
cp .github/workflows/template-01-backend-deploy.yml /path/to/your/backend-repo/.github/workflows/
```

**This ensures the exact same directory structure in your repository:**
```
your-backend-repo/
├── .github/
│   └── workflows/
│       └── template-01-backend-deploy.yml
├── Dockerfile
├── src/
└── ...
```

**Customize Your Configuration:**

**1. Workflow File (`template-01-backend-deploy.yml`):**
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

### 📍 **Step 6: Push All Changes To Your Frontend and Backend Repo**

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

**4. Copy Database Credentials (Important!):**
   ```bash
   # Copy your database credentials from terraform.tfvars before deleting
   # Save these details in a secure location:
   # - Database endpoint
   # - Database name
   # - Username
   # - Password
   # - Port
   ```

**5. Push All Changes to Your Repositories:**

> **⚠️ Security Note**: Never commit sensitive files like `terraform.tfvars` or `.terraform/` folder to your repository. These contain sensitive information and should be kept secure locally.

> **💡 Pro Tip**: Keep a secure backup of your database credentials and other sensitive information from `terraform.tfvars` before removing the file.

---
### 📍 **Step 7: Remove Cloned Repositories**

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

## 📋 **Configuration Options**

### **VPC Configuration**
- **CIDR Block**: Customizable VPC and subnet ranges
- **Availability Zone**: Multi-AZ deployment (us-east-1a, us-east-1b)
- **Security Groups**: Ports 22 (SSH), 80 (HTTP), 8080 (Backend)

### **S3 Configuration**
- **Bucket Name**: Automatically generated as `project_name-environment-random4digit`
- **Access Control**: Private with IAM role-based access
- **Encryption**: AES256 server-side encryption

### **EC2 Configuration**
- **Instance Type**: Configurable (default: t3.micro)
- **AMI**: Latest Ubuntu 22.04 LTS (auto-detected) or custom AMI
- **Storage**: 20GB encrypted GP3 volume
- **Docker**: Automatically installed and configured on instance launch

### **RDS Configuration**
- **Engine**: Latest PostgreSQL version (auto-detected) or custom version
- **Instance Class**: Configurable (default: db.t3.micro)
- **Storage**: 20GB initial, auto-scaling to 100GB
- **Security**: Private subnet, EC2-only access

---

## 🔍 **Troubleshooting**

### **Common Issues**
- **AMI not found**: Let Terraform auto-detect latest Ubuntu, or set `use_custom_ami = true`
- **S3 bucket name conflicts**: Names are automatically generated with random suffixes
- **Insufficient permissions**: Ensure AWS credentials have required permissions
- **SSH connection failed**: Ensure EC2 key pair exists and .pem file has correct permissions (400)


### **Infrastructure Layer (This Step)**
- ✅ VPC with public/private subnets
- ✅ EC2 instance with Docker pre-installed and docker compose file created
- ✅ S3 bucket for file storage
- ✅ RDS PostgreSQL database
- ✅ Security groups and IAM roles


---

## 🎉 **Setup Complete!**

Congratulations! You've successfully:
- ✅ Created GitHub repositories
- ✅ Deployed AWS infrastructure
- ✅ Configured GitHub secrets and variables
- ✅ Deployed sample applications
- ✅ Set up CI/CD ready environment

---


## 🆘 **Need Help?**

If you encounter any issues:

1. **Check Prerequisites**: Ensure all requirements are met
2. **Contact DevOps Team**: Reach out for additional support



