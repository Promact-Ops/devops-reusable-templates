# 🚀 DevOps Reusable Templates

This repository contains a collection of **reusable templates** for setting up full-stack applications with **CI/CD pipelines**, **containerization**, and **cloud infrastructure provisioning**.  
It is designed to **standardize** and **accelerate** the deployment process for modern **frontend** and **backend** frameworks.

---

We are focusing on the following target areas and will add more in the future:

## 🎯 Target Areas

### ☁️ Compute Types

#### **AWS**
- EC2 (Docker Compose)
- ECS (Fargate & EC2)
- CloudFront with S3 *(for static frontend apps)*

#### **Azure**
- Azure VM (Docker Compose)
- Azure Container Apps
- Azure App Service
- Azure CDN with Blob Storage *(for static frontend apps)*

#### **VPS**
- Docker Compose on any VPS provider (e.g., GoDaddy, Hostinger) — ensure internet accessibility

---

### ⚙️ CI/CD

- GitHub Actions

---

### 🏗️ Infrastructure as Code (IaC)

- Terraform

---

## 🧩 Framework Support

### Frontend
- Next.js
- Vite

### Backend
- **.NET**
- **Python**
  - FastAPI
- **Node.js**
  - NestJS
  - Express.js

---

## 📋 Prerequisites

Before using any of the templates, ensure you have the required software and configurations installed:

**📖 [Complete Prerequisites Guide](prerequisites/README.md)**

This includes:
- Required CLI tools based on your chosen template (AWS CLI, Azure CLI, etc.)
- Cloud provider credentials and configuration
- GitHub account with repository admin access
- Basic Git knowledge

---

## 🔄 Available Reusable Templates

- [Template 01 - Deploy Frontend and Backend to AWS EC2, RDS, S3](quickstart-templates/Template-01/README.md)
- [Template 02 - Deploy Frontend and Backend to AWS ECS (EC2/Fargate), RDS, S3](quickstart-templates/Template-02/README.md)
- [Template 03 - Deploy Frontend and Backend to Azure VM, Managed DB, Storage Account](quickstart-templates/Template-03/README.md)
- [Template 04 - Deploy Frontend and Backend to Azure Container Apps, Managed DB, Storage Account](quickstart-templates/Template-04/README.md)
- [Template 05 - Deploy Frontend and Backend to Azure Web Apps, Managed DB, Storage Account](quickstart-templates/Template-05/README.md)
- [Template 06 - Deploy Frontend and Backend to VPS](quickstart-templates/Template-06/README.md)

---

Maintained by the **DevOps Team**

