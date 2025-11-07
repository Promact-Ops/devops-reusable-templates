# 🚀 Terraform VPS Docker Setup Automation

This project automates the setup of a VPS with Docker and Docker Compose using **Terraform** and a **remote provisioning script** (`setup.sh`).  
It’s ideal for deploying and configuring Docker environments on **Ubuntu 22.04 / 24.04** servers (e.g., Azure, AWS, or DigitalOcean).

---

## 🧩 Project Structure

```

.
├── main.tf             # Terraform infrastructure definition
├── variables.tf        # Input variables for the setup
├── setup.sh            # Remote script to install Docker & prepare project
├── .github/
│   └── workflows/
│       └── terraform.yml   # GitHub Actions CI/CD pipeline
└── README.md

```

---

## ⚙️ How It Works

1. **Terraform** connects to your VPS using SSH.
2. The `setup.sh` script is uploaded and executed remotely.
3. The script:
   - Installs **Docker Engine** and **Docker Compose**
   - Configures system users and permissions
   - Creates a base **project directory structure**
   - Fetches a Docker Compose template from GitHub and customizes it dynamically

---

## 🧰 Prerequisites

- Terraform ≥ **1.3**
- Ubuntu VPS (22.04 (tested) or 24.04 (not tested))
- SSH access to VPS
- A valid private key

---

## 🔧 Configuration

Define variables in `variables.tf` or via `terraform.tfvars`:

```hcl
vps_ip            = "YOUR_VPS_IP"
private_key_path  = "~/.ssh/id_rsa"
project_name      = "myapp"
environment       = "staging"
````

---

## 🚀 Usage

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan infrastructure changes
terraform plan

# Apply configuration
terraform apply -auto-approve
```

Once applied, Terraform will:

* SSH into your VPS
* Install and configure Docker automatically
* Prepare a `/home/ubuntu/_<project>-<environment>-server/` directory with a ready-to-use `docker-compose.yml`

---

## 🧾 Example Output

```
Docker installation completed successfully!
Docker version: 27.3.1
Docker Compose version: v2.28.0
Project folder: /home/ubuntu/_myapp-staging-server
```

---

## 🧩 File Details

### `setup.sh`

* Handles all Docker installation and setup logic.
* Creates folder structure:

```
/home/ubuntu/_<PROJECT>-<ENV>-server/
├── frontend/
├── backend/
└── docker-compose.yml
```

### `main.tf`

* Manages file upload and remote execution via Terraform provisioners.

### `variables.tf`

* Defines the configurable inputs like `project_name`, `environment`, and SSH credentials.

---

## 🧪 Tested On

| OS Version   | Status |
| ------------ | ------ |
| Ubuntu 22.04 | ✅     |

---


## 🔐 Secrets Required

Store the following secrets in your GitHub repository:

| Secret Name | Description |
|--------------|-------------|
| `VPS_IP` | Public IP of the target VPS |
| `PRIVATE_KEY` | SSH private key to access VPS |
| `project_name` | Terraform variable for project name |
| `environment` | Terraform variable for environment |

---
