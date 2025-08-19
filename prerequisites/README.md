# 📋 **Prerequisites**

Before starting with the DevOps templates, ensure you have the following prerequisites installed and configured:

### **Install and Configure AWS CLI**

**For Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install awscli
```

**Alternative method (if apt method fails):**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**For macOS:**
```bash
brew install awscli
```

**For Windows:**
```bash
# Download from: https://aws.amazon.com/cli/
```

**Verify Installation:**
```bash
aws --version
```

> **If you're still unable to install AWS CLI, check the official documentation**: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

**AWS CLI Configuration**

1: Get AWS Access Keys**

1. **Go to AWS Console:**
   - Navigate to AWS Console → IAM → Users → Your User
   - Click "Security credentials" tab
   - Click "Create access key"
   - Choose "Command Line Interface (CLI)"
   - **Important**: Download the CSV file with your access key ID and secret access key

2: Configure AWS CLI**

```bash
aws configure
```

Enter the following when prompted:
```
AWS Access Key ID: [Your Access Key ID]
AWS Secret Access Key: [Your Secret Access Key]
Default region name: us-east-1
Default output format: json
```

3: Verify Configuration**

```bash
aws sts get-caller-identity
```

This command should return your AWS account information, confirming successful configuration.


**Security Best Practices**

- **Never commit AWS credentials** to version control
- **Rotate access keys** regularly
- **Use least privilege principle** for IAM permissions



---

### **Terraform CLI Installation**

**For Ubuntu/Debian:**
```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**For macOS:**
```bash
brew install terraform
```

**For Windows:**
```bash
# Download from: https://www.terraform.io/downloads
```

**Verify Installation:**
```bash
terraform --version
```


---


Once all prerequisites are met, you can proceed to the templates
