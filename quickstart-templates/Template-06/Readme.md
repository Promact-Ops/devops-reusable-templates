# 🚀 Template 06 - Deploy Frontend and Backend to VPS
This template creates a complete, VPS infrastructure (tested in Ubuntu 22) along with a CI/CD pipeline, seamlessly integrating with your existing frontend and backend repositories.

**The following cloud services will be created using this template:**
| Service | Purpose | Details |
|---------|---------|---------|
| **VPS** | deployment | VPS Connection (VPS/Host IP, Username and Access Key) |


### 📋 **Prerequisites**

Before starting, ensure you have all the required software and configurations installed. 

**Access to VPS - Host IP, Username and Access Key**

**Repository Requirements**: Ensure your existing frontend and backend repositories are already cloned locally for Infrastructure and CI/CD setup. 

---

### 🚀 **Quick Start Guide**

This guide will walk you through setting up your environment and deploying your applications VPS.


#### **Step 1: Connect to VPS**

> **📖 Detailed Guide**: Connect to VPS using (Host IP, Username and Access Key), once you are in VPS follow next steps.

> **📖 Switch to root user**: ```sudo su```

#### **Step 2: Download script using CURL OR Wget**

> **📖 CURL Guide**: ```curl -o setup_template-06.sh https://raw.githubusercontent.com/Promact-Ops/devops-docker-templates/refs/heads/jaydeep-template-6/scripts/setup_template-06.sh```

> **📖 Wget Guide**: ```wget -O setup_template-06.sh https://raw.githubusercontent.com/Promact-Ops/devops-docker-templates/refs/heads/jaydeep-template-6/scripts/setup_template-06.sh```

#### **Step 3: Setup Environment variables and execute the script**

######  After downloading the script to VPS, run this command in VPS to set environment variables that will be used by script:
##### NOTE: Provide the values according to your VPS or cloud VPS provider
```
export PROJECT_NAME=
export ENVIRONMENT=
export VPS_USER_NAME=

## Verify
echo $PROJECT_NAME
echo $ENVIRONMENT
echo $VPS_USER_NAME
```

###### - Then make script executable using this command:
```
chmod +x setup_template-06.sh
```

###### - Then execute the script using this command:
```
./setup_template-06.sh
```

---

🔄 **What Happens Next?**

After successfully deploying your infrastructure in VPS:

---

## **Frontend and Backend Deployment Setup**: 
#### **Step 1: Set Up GitHub Secrets and Variables**

1. **Go to Your Frontend Repository:**
   - Navigate to Settings → Secrets and variables → Actions
   - Create the required **secrets** (3):
     - `SERVER_SSH_KEY` - Your .pem file content
     - `SERVER_HOST` - From VPS
     - `SERVER_USER` - From VPS
   - Create the required **variables** (4):
     - `FRONTEND_PATH` - From VPS
     - `BACKEND_PATH` - From VPS
     - `DOCKER_COMPOSE_PATH` - From VPS
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
cp .github/workflows/template-06-backend-deploy.yaml /path/to/your/backend-repo/.github/workflows/
```

**This ensures the exact same directory structure in your repository:**
```
your-backend-repo/
├── .github/
│   └── workflows/
│       └── template-06-backend-deploy.yaml
├── Dockerfile
├── src/
└── ...
```

**Customize Your Configuration:**

**1. Workflow File (`template-06-backend-deploy.yaml`):**
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
