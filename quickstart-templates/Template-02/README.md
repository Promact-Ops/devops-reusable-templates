# 🚀 Template 02 - Deploy Frontend and Backend to AWS ECS, RDS, S3

This template creates a complete, production-ready AWS infrastructure using ECS (Elastic Container Service) with support for both EC2 and Fargate launch types, along with a CI/CD pipeline that seamlessly integrates with your existing frontend and backend repositories.

## 📊 Cloud Services Overview

The following cloud services will be created using this template:

| Service | Purpose | Details |
|---------|---------|---------|
| **VPC** | Network isolation | Public/private subnets, NAT Gateway, Internet Gateway |
| **ECS Cluster** | Container orchestration | Supports both EC2 and Fargate launch types |
| **Application Load Balancer** | Traffic distribution | Path-based routing for frontend/backend |
| **ECR** | Container registry | Private Docker image repositories |
| **S3** | File storage | Encrypted, versioned, IAM-controlled access |
| **RDS** | Database | PostgreSQL with automated backups and monitoring |
| **IAM** | Security | Task execution roles, service roles |
| **CloudWatch** | Monitoring | Logs, metrics, and alarms |
| **Security Groups** | Network security | ALB, ECS tasks, RDS access control |

## 📋 Prerequisites

Before starting, ensure you have all the required software and configurations installed.

**→ Complete Prerequisites Guide**

**Repository Requirements:** Ensure your existing frontend and backend repositories are already cloned locally for Infrastructure and CI/CD setup.

This includes:

- ✅ AWS Account with administrator access
- ✅ Basic Git knowledge and command line experience
- ✅ AWS CLI installed and configured
- ✅ Terraform CLI installed and working
- ✅ Docker installed locally (for testing)
- ✅ GitHub account with repository access

---

## 🚀 Quick Start Guide

This guide will walk you through setting up your environment and deploying your applications to AWS ECS infrastructure.

💡 **Pro Tip:** Each step builds on the previous one. Follow the process in order for the best experience.

---

## Step 1: Create AWS Infrastructure Using Terraform

### A. AWS CLI Configuration

📖 **AWS CLI Configuration is covered in the Prerequisites Guide**

Ensure you have completed the AWS CLI setup before proceeding with this step.

### B. Clone the Repository

**Using HTTPS:**
```bash
git clone https://github.com/Promact-Ops/devops-reusable-templates.git
```

**Using SSH (if you have SSH keys configured):**
```bash
git clone git@github.com:Promact-Ops/devops-reusable-templates.git
```

### C. Copy Terraform Files to Your Repository

1. **Navigate to the Terraform directory:**
```bash
cd devops-reusable-templates/quickstart-templates/Template-02/IaC/terraform
```

2. **Copy the Terraform files to your existing backend/frontend repository:**
   - Create an `Infrastructure` folder in your repository
   - Copy all files from the terraform directory to your repository's Infrastructure folder
   - This ensures you have the infrastructure code in your own repository for version control

**Benefits:** Your infrastructure code stays with your application code, making it easier to manage changes and track infrastructure evolution.

**Example structure in your repository:**
```
your-repo/
├── Infrastructure/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── vpc.tf
│   ├── ecs.tf
│   ├── alb.tf
│   ├── ecr.tf
│   ├── rds.tf
│   ├── s3.tf
│   └── iam.tf
├── src/
├── README.md
└── ...
```

### D. Configure Variables

1. **Navigate to your repository's Infrastructure folder:**
```bash
cd /path/to/your/repo/Infrastructure
```

2. **Copy the example variables file:**
```bash
cp terraform.tfvars.example terraform.tfvars
```

3. **Edit terraform.tfvars with your project details:**
```bash
vim terraform.tfvars
```

### 📋 Terraform Variables Options

#### General Configuration
- **Project Name:** Your project identifier
- **Environment:** dev, staging, production
- **AWS Region:** us-east-1, us-west-2, etc.

#### VPC Configuration
- **CIDR Block:** Customizable VPC and subnet ranges
- **Availability Zones:** Multi-AZ deployment for high availability
- **NAT Gateway:** Single or Multi-AZ NAT Gateway

#### ECS Configuration
- **Launch Type:** EC2, FARGATE, or BOTH
- **EC2 Instance Type:** t3.micro, t3.small, t3.medium (if using EC2 launch type)
- **Task CPU/Memory:** Configurable resources for containers
- **Auto Scaling:** Min/max task counts, target CPU utilization
- **Service Discovery:** Enable/disable AWS Cloud Map integration

#### ECR Configuration
- **Image Scanning:** Automated vulnerability scanning
- **Image Retention:** Lifecycle policies for image management
- **Encryption:** KMS encryption for images

#### Application Load Balancer
- **Health Check:** Path, interval, timeout configuration
- **SSL/TLS:** Certificate ARN for HTTPS (optional)
- **Routing:** Path-based routing rules

#### RDS Configuration
- **Engine:** PostgreSQL (latest version or custom)
- **Instance Class:** db.t3.micro, db.t3.small, db.t3.medium
- **Storage:** Initial size and auto-scaling limits
- **Multi-AZ:** Enable for high availability
- **Backup:** Retention period and backup window

#### S3 Configuration
- **Bucket Name:** Auto-generated with project name
- **Versioning:** Enable/disable object versioning
- **Encryption:** AES256 or KMS encryption

### E. Initialize and Deploy

1. **Initialize Terraform:**
```bash
terraform init
```

2. **Review the deployment plan:**
```bash
terraform plan
```

3. **Deploy the infrastructure:**
```bash
terraform apply
```

**Note:** This will ask for your approval to create the infrastructure. Enter `yes` to proceed.

4. **Save the Output:**
```bash
terraform output github_secrets_setup_guide
```

### 🔄 What Happens Next?

After successfully deploying your infrastructure with Terraform:

1. **Save the Output:** Run `terraform output github_secrets_setup_guide` to get infrastructure details
2. **Continue to Step 2:** Create GitHub Repositories
3. **Prepare for Deployment:** Your ECS cluster will be ready to receive containers
4. **Get Connection Details:** Use the outputs to configure your GitHub repositories

**Key Outputs You'll Need:**
- ECR Repository URLs for frontend and backend
- Application Load Balancer DNS name
- ECS Cluster name and service names
- S3 Bucket details
- RDS Endpoint and credentials

---

## Step 2: Set Up GitHub Secrets and Variables

### Go to Your Frontend Repository

1. Navigate to **Settings → Secrets and variables → Actions**

2. **Create the required secrets (5):**
   - `AWS_ACCOUNT_ID` - Your AWS account ID
   - `AWS_REGION` - AWS region (e.g., us-east-1)
   - `AWS_ACCESS_KEY_ID` - AWS access key
   - `AWS_SECRET_ACCESS_KEY` - AWS secret key
   - `RDS_PASSWORD` - Database password from Terraform output

3. **Create the required variables (6):**
   - `ECR_FRONTEND_REPOSITORY` - From Terraform output
   - `ECS_CLUSTER_NAME` - From Terraform output
   - `ECS_FRONTEND_SERVICE` - From Terraform output
   - `ECS_FRONTEND_TASK_DEFINITION` - From Terraform output
   - `FRONTEND_APP_ENV` - Your app environment variables (JSON format)
   - `S3_BUCKET_NAME` - From Terraform output

### Go to Your Backend Repository

1. Navigate to **Settings → Secrets and variables → Actions**

2. **Create the required secrets (5):**
   - Use the same AWS secrets as frontend
   - `RDS_PASSWORD` - Database password from Terraform output

3. **Create the required variables (7):**
   - `ECR_BACKEND_REPOSITORY` - From Terraform output
   - `ECS_CLUSTER_NAME` - From Terraform output
   - `ECS_BACKEND_SERVICE` - From Terraform output
   - `ECS_BACKEND_TASK_DEFINITION` - From Terraform output
   - `RDS_ENDPOINT` - From Terraform output
   - `RDS_DATABASE_NAME` - From Terraform output
   - `S3_BUCKET_NAME` - From Terraform output

---

## Step 3: Clone Sample Code Repository

### 📚 Sample Code Repository Reference

After setting up your GitHub secrets and variables, you'll need to clone sample code from the official repository:

**Repository:** https://github.com/Promact-Ops/devops-docker-templates.git

**What's Available:**
- Frontend Templates: Next.js, Vite, React, Vue.js
- Backend Templates: Node.js, Python FastAPI, .NET, Java
- ECS Task Definitions: Ready-to-use configurations
- Sample Applications: Complete working examples

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
└── ecs-task-definitions/
    ├── frontend-task-def.json
    └── backend-task-def.json
```

💡 **Pro Tip:** This repository contains production-ready templates that you can customize for your specific needs.

**Clone the sample code repository:**
```bash
git clone https://github.com/Promact-Ops/devops-docker-templates.git
cd devops-docker-templates/sample-repos
```

---

## Step 4: Set Up Frontend Repository

### Navigate to Your Preferred Frontend Framework

**Example: Next.js**
```bash
cd devops-docker-templates/sample-repos/frontend/nextjs
```

### Copy Required Files to Your Repository

**1. Copy the Dockerfile:**
```bash
cp Dockerfile /path/to/your/frontend-repo/
```

**2. Copy the GitHub workflow file with exact directory structure:**
```bash
# Create the .github/workflows directory in your repository
mkdir -p /path/to/your/frontend-repo/.github/workflows

# Copy the workflow file
cp .github/workflows/template-02-frontend-ecs-deploy.yml /path/to/your/frontend-repo/.github/workflows/
```

**This ensures the exact same directory structure in your repository:**
```
your-frontend-repo/
├── .github/
│   └── workflows/
│       └── template-02-frontend-ecs-deploy.yml
├── Dockerfile
├── src/
└── ...
```

### Customize Your Configuration

**1. Workflow File (template-02-frontend-ecs-deploy.yml):**

- You can rename the file to any name you prefer (e.g., `deploy.yml`, `ci-cd.yml`, `production-deploy.yml`)
- Open the file and customize:

```yaml
name: Frontend ECS Deploy  # Change to your preferred name

on:
  workflow_dispatch:
  push:
    branches:
      - main  # Update to your branch name (dev, develop, staging, production)
```

**2. Dockerfile:**

- This example is for Next.js projects - for other frameworks, check the sample repository
- For Next.js projects, you can change the CMD value according to your package.json scripts:
  - `CMD ["npm", "start"]` - for production builds
  - `CMD ["npm", "run", "dev"]` - for development mode
  - `CMD ["node", "server.js"]` - if you have a custom server

---

## Step 5: Set Up Backend Repository

### Navigate to Your Preferred Backend Framework

**Example: Express.js**
```bash
cd devops-docker-templates/sample-repos/backend/nodejs-expressjs/
```

### Copy Required Files to Your Repository

**1. Copy the Dockerfile:**
```bash
cp Dockerfile /path/to/your/backend-repo/
```

**2. Copy the GitHub workflow file with exact directory structure:**
```bash
# Create the .github/workflows directory in your repository
mkdir -p /path/to/your/backend-repo/.github/workflows

# Copy the workflow file
cp .github/workflows/template-02-backend-ecs-deploy.yml /path/to/your/backend-repo/.github/workflows/
```

**This ensures the exact same directory structure in your repository:**
```
your-backend-repo/
├── .github/
│   └── workflows/
│       └── template-02-backend-ecs-deploy.yml
├── Dockerfile
├── src/
└── ...
```

### Customize Your Configuration

**1. Workflow File (template-02-backend-ecs-deploy.yml):**

- You can rename the file to any name you prefer
- Open the file and customize:

```yaml
name: Backend ECS Deploy  # Change to your preferred name

on:
  workflow_dispatch:
  push:
    branches:
      - main  # Update to your branch name
```

**2. Dockerfile:**

- Check the sample repository for framework-specific configurations
- Update any framework-specific settings (e.g., project names, entry points)

---

## Step 6: Push All Changes To Your Repositories

### Before Pushing - Important Cleanup Steps

**1. Remove Terraform Generated Files:**
```bash
# Remove the .terraform folder (generated by terraform init)
rm -rf .terraform/

# Remove .terraform.lock.hcl file if present
rm -f .terraform.lock.hcl
```

**2. Remove Sensitive Configuration Files:**
```bash
# Backup terraform.tfvars file on your local machine before removing
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

💡 **Backup Note:** The terraform.tfvars.backup file contains your project configuration and will be useful when you need to add/update any configuration in your cloud resources in the future.

**4. Copy Important Credentials (Important!):**
Save these details in a secure location:
- RDS endpoint, database name, username, password, port
- ECR repository URLs
- AWS Account ID and Region
- S3 bucket names
- Load Balancer DNS name

**5. Push All Changes to Your Repositories:**

⚠️ **Security Note:** Never commit sensitive files like `terraform.tfvars` or `.terraform/` folder to your repository.

---

## Step 7: Remove Cloned Repositories

Return to directory where we cloned the repositories and remove them:

```bash
# Remove sample code repository
rm -rf devops-docker-templates

# Remove infrastructure templates repository
rm -rf devops-reusable-templates
```

**Note:** Your infrastructure code is now safely stored in your own repository's Infrastructure folder.

---

## 🎯 Architecture Overview

```
                                    ┌─────────────────┐
                                    │   Internet      │
                                    └────────┬────────┘
                                             │
                                    ┌────────▼────────┐
                                    │ Application     │
                                    │ Load Balancer   │
                                    └────────┬────────┘
                                             │
                        ┌────────────────────┼────────────────────┐
                        │                    │                    │
                 ┌──────▼──────┐      ┌─────▼──────┐      ┌─────▼──────┐
                 │   Target    │      │   Target   │      │   Target   │
                 │   Group     │      │   Group    │      │   Group    │
                 │ (Frontend)  │      │ (Backend)  │      │  (Future)  │
                 └──────┬──────┘      └─────┬──────┘      └─────┬──────┘
                        │                    │                    │
              ┌─────────┴─────────┐  ┌──────┴──────┐   ┌─────────┴──────┐
              │                   │  │             │   │                │
       ┌──────▼──────┐    ┌──────▼──▼──┐   ┌──────▼───▼──┐    ┌────────▼─────┐
       │  ECS Task   │    │  ECS Task   │   │  ECS Task   │    │  ECS Task    │
       │ (Frontend)  │    │ (Frontend)  │   │ (Backend)   │    │  (Backend)   │
       │  Fargate/   │    │  Fargate/   │   │  Fargate/   │    │  Fargate/    │
       │    EC2      │    │    EC2      │   │    EC2      │    │    EC2       │
       └──────┬──────┘    └──────┬──────┘   └──────┬──────┘    └──────┬───────┘
              │                  │                  │                  │
              └──────────────────┴──────────────────┴──────────────────┘
                                         │
                        ┌────────────────┼────────────────┐
                        │                │                │
                 ┌──────▼──────┐  ┌─────▼──────┐  ┌──────▼──────┐
                 │     RDS     │  │     S3     │  │  CloudWatch │
                 │ (PostgreSQL)│  │  (Storage) │  │   (Logs)    │
                 └─────────────┘  └────────────┘  └─────────────┘
```

---

## 🔍 Troubleshooting Common Issues

### ECS Tasks Not Starting
- Check CloudWatch logs for task errors
- Verify ECR image exists and is accessible
- Check task execution role permissions
- Ensure security groups allow proper traffic

### Load Balancer Health Checks Failing
- Verify health check path is correct
- Check if application is listening on correct port
- Review security group rules
- Check target group settings

### ECR Push Failures
- Ensure AWS credentials are correct
- Verify ECR repository exists
- Check IAM permissions for ECR
- Authenticate Docker to ECR

### Database Connection Issues
- Verify RDS security group allows ECS tasks
- Check database credentials
- Ensure database is in private subnet
- Verify connection string format

### Insufficient Permissions
- Ensure AWS credentials have required permissions
- Check task execution role policies
- Verify service role policies

---

## 📊 Monitoring and Logging

### CloudWatch Logs
All ECS tasks automatically send logs to CloudWatch:
- Log Group: `/ecs/{project-name}/{environment}`
- Frontend Stream: `frontend/{task-id}`
- Backend Stream: `backend/{task-id}`

### CloudWatch Metrics
Monitor your application with:
- CPU Utilization
- Memory Utilization
- Request Count
- Target Response Time
- HTTP 4xx/5xx errors

### Setting Up Alarms
Create CloudWatch alarms for:
- High CPU usage (> 80%)
- High memory usage (> 80%)
- Unhealthy target count
- High 5xx error rate

---

## 🔐 Security Best Practices

1. **Use Secrets Manager:** Store sensitive data in AWS Secrets Manager instead of environment variables
2. **Enable VPC Flow Logs:** Monitor network traffic
3. **Implement WAF:** Add AWS WAF for additional security
4. **Use HTTPS:** Configure SSL/TLS certificates on ALB
5. **Rotate Credentials:** Regularly rotate database passwords and access keys
6. **Enable MFA:** Require MFA for AWS console access
7. **Least Privilege:** Apply principle of least privilege for IAM roles
8. **Scan Images:** Enable ECR image scanning for vulnerabilities

---

## 🚀 Scaling Your Application

### Auto Scaling Configuration

ECS Service Auto Scaling is configured based on:
- **Target CPU Utilization:** Default 70%
- **Min Tasks:** Configurable (default: 1)
- **Max Tasks:** Configurable (default: 10)

### Manual Scaling

Update the desired count in Terraform:
```hcl
desired_count = 3  # Increase/decrease as needed
```

Then apply changes:
```bash
terraform apply
```

---

## 💰 Cost Optimization Tips

1. **Use Fargate Spot:** Save up to 70% on compute costs
2. **Right-size Resources:** Match CPU/memory to actual usage
3. **Use Reserved Capacity:** For predictable workloads
4. **Enable S3 Lifecycle Policies:** Transition old data to cheaper storage classes
5. **Use RDS Reserved Instances:** For long-term database usage
6. **Delete Unused Resources:** Regularly audit and remove unused infrastructure
7. **Use CloudWatch Insights:** Identify optimization opportunities

---

## 🎉 Setup Complete!

Congratulations! You've successfully:

- ✅ Created AWS ECS infrastructure with Terraform
- ✅ Configured ECR repositories for container images
- ✅ Set up Application Load Balancer with path-based routing
- ✅ Deployed RDS database with automated backups
- ✅ Created S3 buckets for file storage
- ✅ Configured GitHub secrets and variables
- ✅ Set up CI/CD pipelines for automated deployments
- ✅ Deployed sample applications to ECS

### 🔗 Access Your Application

- **Frontend:** `http://<alb-dns-name>/`
- **Backend API:** `http://<alb-dns-name>/api`
- **Health Check:** `http://<alb-dns-name>/health`

### 📈 Next Steps

1. **Configure Custom Domain:** Point your domain to ALB DNS
2. **Enable HTTPS:** Add SSL/TLS certificate to ALB
3. **Set Up Monitoring:** Create CloudWatch dashboards
4. **Implement Backups:** Configure automated backup strategies
5. **Add WAF Rules:** Enhance security with AWS WAF
6. **Optimize Costs:** Review and right-size resources

---

## 🆘 Need Help?

If you encounter any issues:

- **Check Prerequisites:** Ensure all requirements are met
- **Review Logs:** Check CloudWatch logs for detailed errors
- **AWS Documentation:** Refer to official AWS ECS documentation
- **Contact DevOps Team:** Reach out for additional support

---

## 📚 Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Version:** 1.0.0  
**Last Updated:** November 2025  
**Maintained By:** DevOps Team