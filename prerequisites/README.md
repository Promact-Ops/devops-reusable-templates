# 📋 **Prerequisites**

Before starting with the DevOps templates, ensure you have the following prerequisites installed and configured:

## 🎯 **Required Accounts**

- ✅ **GitHub Account** with repository admin access (so you can create secrets and variables in the repo)
- ✅ **AWS Account** with administrator access
- ✅ **Basic Git knowledge** and command line experience

## 🛠️ **Required Software Installation**

### **1. AWS CLI Installation**

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

**If you're still unable to install AWS CLI, check the official documentation**: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

### **2. Terraform CLI Installation**

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
aws --version
```

> **🔑 AWS Access Required**: You'll need AWS access key ID and secret access key to configure AWS CLI. These are created in the AWS IAM console.

---

## ⚙️ **AWS CLI Configuration**

### **Step 1: Get AWS Access Keys**

1. **Go to AWS Console:**
   - Navigate to AWS Console → IAM → Users → Your User
   - Click "Security credentials" tab
   - Click "Create access key"
   - Choose "Command Line Interface (CLI)"
   - **Important**: Download the CSV file with your access key ID and secret access key

### **Step 2: Configure AWS CLI**

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

### **Step 3: Verify Configuration**

```bash
aws sts get-caller-identity
```

This command should return your AWS account information, confirming successful configuration.

---

## 🔐 **Security Best Practices**

- **Never commit AWS credentials** to version control
- **Use IAM roles** when possible instead of access keys
- **Rotate access keys** regularly
- **Use least privilege principle** for IAM permissions
- **Enable MFA** for your AWS account

---

## 📚 **Additional Resources**

- [AWS CLI Official Documentation](https://docs.aws.amazon.com/cli/)
- [Terraform Official Documentation](https://www.terraform.io/docs)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [GitHub SSH Key Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

## ✅ **Verification Checklist**

Before proceeding to the next steps, ensure you have:

- [ ] AWS CLI installed and working
- [ ] Terraform CLI installed and working
- [ ] AWS credentials configured
- [ ] AWS CLI configuration verified
- [ ] GitHub account access
- [ ] Basic Git knowledge

Once all prerequisites are met, you can proceed to the templates
