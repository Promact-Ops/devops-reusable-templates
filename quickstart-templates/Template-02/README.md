# AWS ECS Fargate Infrastructure with Terraform

This Terraform configuration creates a complete AWS infrastructure for running containerized applications using **ECS Fargate** (serverless containers). It includes VPC, S3, ECS, Application Load Balancer, and RDS PostgreSQL database.

## 🏗️ Architecture Overview

### Components Created

- **VPC**: Multi-AZ VPC with public and private subnets
- **ECS Fargate**: Serverless container orchestration
- **Application Load Balancer**: HTTP/HTTPS traffic routing
- **RDS PostgreSQL**: Managed database with encryption and backups
- **S3**: Encrypted bucket for application storage
- **ECR**: Container image repositories
- **CloudWatch**: Logging and monitoring with alarms
- **Secrets Manager**: Secure database password storage
- **Auto Scaling**: Automatic task scaling based on CPU/Memory

### Network Architecture

```
Internet → ALB (Public Subnets) → ECS Tasks (Private Subnets) → RDS (Private Subnets)
                                    ↓
                                   NAT Gateway → Internet (for pulling images)
```

## 📋 Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0
3. **AWS CLI** configured with credentials
4. **Docker images** ready to push to ECR
5. **(Optional)** SSL Certificate ARN for HTTPS

## 🚀 Quick Start

### 1. Clone and Initialize

```bash
# Clone your repository
git clone <your-repo-url>
cd <repo-directory>

# Initialize Terraform
terraform init
```

### 2. Configure Variables

Create a `terraform.tfvars` file:

```hcl
# Project Configuration
project_name = "myapp"
environment  = "production"
aws_region   = "us-east-1"
owner        = "DevOps Team"

# VPC Configuration
vpc_cidr                    = "10.0.0.0/16"
availability_zone           = "us-east-1a"
private_subnet_cidr         = "10.0.1.0/24"
second_private_subnet_cidr  = "10.0.2.0/24"
public_subnet_cidr          = "10.0.101.0/24"
second_public_subnet_cidr   = "10.0.102.0/24"
single_nat_gateway          = false  # Set true for cost savings in dev

# ECS Fargate Configuration
frontend_task_cpu     = "256"
frontend_task_memory  = "512"
backend_task_cpu      = "512"
backend_task_memory   = "1024"
frontend_desired_count = 2
backend_desired_count  = 2

# Auto Scaling
enable_autoscaling         = true
frontend_min_tasks         = 1
frontend_max_tasks         = 10
backend_min_tasks          = 1
backend_max_tasks          = 10
target_cpu_utilization     = 70
target_memory_utilization  = 80

# RDS Configuration
rds_instance_class         = "db.t3.micro"
rds_allocated_storage      = 20
rds_max_allocated_storage  = 100
rds_db_name                = "appdb"
rds_username               = "dbadmin"
rds_password               = "ChangeMe123!SecurePassword"  # Use strong password
rds_multi_az               = true
rds_backup_retention_period = 7

# Health Check Configuration
frontend_health_check_path = "/"
backend_health_check_path  = "/health"
health_check_interval      = 30
health_check_timeout       = 5
healthy_threshold          = 2
unhealthy_threshold        = 3

# HTTPS Configuration (Optional)
enable_https    = false
certificate_arn = ""  # Add your ACM certificate ARN

# ECR Configuration
ecr_image_retention_count = 10

# Logging
log_retention_days = 7

# Common Tags
common_tags = {
  ManagedBy = "Terraform"
  CostCenter = "Engineering"
}
```

### 3. Plan and Apply

```bash
# Review the planned changes
terraform plan

# Apply the configuration
terraform apply

# Save important outputs
terraform output > outputs.txt
```

### 4. Build and Push Docker Images

```bash
# Get ECR login credentials
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build and push frontend
docker build -t myapp-production-frontend ./frontend
docker tag myapp-production-frontend:latest <frontend-ecr-url>:latest
docker push <frontend-ecr-url>:latest

# Build and push backend
docker build -t myapp-production-backend ./backend
docker tag myapp-production-backend:latest <backend-ecr-url>:latest
docker push <backend-ecr-url>:latest

# Force new deployment
aws ecs update-service --cluster myapp-production-cluster --service myapp-production-frontend --force-new-deployment
aws ecs update-service --cluster myapp-production-cluster --service myapp-production-backend --force-new-deployment
```

## 📊 Key Features

### 1. **Serverless with Fargate**
- No EC2 instances to manage
- Pay only for container resources used
- Automatic scaling and patching
- Ideal for variable workloads

### 2. **High Availability**
- Multi-AZ deployment
- Auto Scaling based on CPU/Memory
- Health checks and automatic task replacement
- Load balancer with cross-zone enabled

### 3. **Security**
- Private subnets for containers and database
- Security groups with least privilege
- Encrypted storage (S3, RDS, EBS)
- Secrets Manager for sensitive data
- VPC isolation

### 4. **Monitoring**
- CloudWatch Logs for all containers
- Container Insights enabled
- CloudWatch Alarms for:
  - RDS CPU, Memory, Storage
  - ALB response time and unhealthy targets
  - Custom metrics available

### 5. **Cost Optimization**
- Fargate Spot support available
- Auto Scaling to match demand
- S3 lifecycle policies
- ECR image cleanup policies

## 🔧 Configuration Options

### Task Sizing (CPU/Memory Combinations)

Fargate supports specific CPU/Memory combinations:

| CPU (vCPU) | Memory (GB) Options |
|------------|---------------------|
| 0.25       | 0.5, 1, 2          |
| 0.5        | 1, 2, 3, 4         |
| 1          | 2, 3, 4, 5, 6, 7, 8|
| 2          | 4 to 16 (1GB incr) |
| 4          | 8 to 30 (1GB incr) |

### Environment-Specific Settings

**Development:**
```hcl
single_nat_gateway     = true   # Cost savings
rds_multi_az          = false  # Single AZ
frontend_desired_count = 1
backend_desired_count  = 1
enable_autoscaling    = false
```

**Production:**
```hcl
single_nat_gateway     = false  # High availability
rds_multi_az          = true   # Multi-AZ
frontend_desired_count = 2
backend_desired_count  = 2
enable_autoscaling    = true
```

## 📡 Accessing Your Application

After deployment:

```bash
# Get ALB DNS name
terraform output alb_dns_name

# Access frontend
http://<alb-dns-name>

# Access backend API
http://<alb-dns-name>/api

# Health check
http://<alb-dns-name>/health
```

## 🔐 Security Best Practices

1. **Secrets Management**
   - Store RDS password in Secrets Manager (already configured)
   - Use AWS Systems Manager Parameter Store for app configs
   - Never commit secrets to version control

2. **Network Security**
   - Containers in private subnets (no direct internet access)
   - Security groups with minimal permissions
   - Use VPC endpoints for AWS services (optional improvement)

3. **Database Security**
   - Not publicly accessible
   - Encrypted at rest
   - Automated backups
   - Change default passwords immediately

4. **SSL/TLS**
   ```hcl
   enable_https = true
   certificate_arn = "arn:aws:acm:region:account:certificate/xxx"
   ```

## 📈 Monitoring and Debugging

### View Logs

```bash
# Frontend logs
aws logs tail /ecs/myapp-production --follow --filter-pattern "frontend"

# Backend logs
aws logs tail /ecs/myapp-production --follow --filter-pattern "backend"
```

### Check Service Status

```bash
# List services
aws ecs list-services --cluster myapp-production-cluster

# Describe service
aws ecs describe-services --cluster myapp-production-cluster --services myapp-production-frontend

# List tasks
aws ecs list-tasks --cluster myapp-production-cluster --service-name myapp-production-frontend
```

### Common Issues

**Tasks failing to start:**
- Check CloudWatch Logs for container errors
- Verify ECR images exist and are accessible
- Check task execution role permissions
- Ensure sufficient CPU/Memory allocation

**Database connection issues:**
- Verify security group rules
- Check RDS endpoint in task environment variables
- Validate credentials in Secrets Manager

**Images not pulling:**
- Ensure NAT Gateway is properly configured
- Check task execution role has ECR permissions
- Verify private subnet routes to NAT Gateway

## 💰 Cost Estimation

**Monthly costs (approximate):**

| Service | Configuration | Est. Cost |
|---------|--------------|-----------|
| ECS Fargate (2 tasks @ 0.5 vCPU, 1GB) | 24/7 | ~$35 |
| ALB | 1 ALB | ~$20 |
| NAT Gateway | 1 or 2 | ~$35-70 |
| RDS (db.t3.micro) | Single-AZ | ~$15 |
| RDS (db.t3.micro) | Multi-AZ | ~$30 |
| Data Transfer | Varies | $10-50 |
| **Total (Dev)** | | **~$115** |
| **Total (Prod)** | | **~$150-180** |

**Cost optimization tips:**
- Use Fargate Spot for non-critical workloads (70% savings)
- Single NAT Gateway for dev environments
- Right-size tasks based on actual usage
- Implement Auto Scaling to scale down during low traffic

## 🔄 Updates and Maintenance

### Update Task Definitions

```bash
# After code changes and new image push
aws ecs update-service \
  --cluster myapp-production-cluster \
  --service myapp-production-frontend \
  --force-new-deployment
```

### Scaling Services Manually

```bash
# Scale frontend to 5 tasks
aws ecs update-service \
  --cluster myapp-production-cluster \
  --service myapp-production-frontend \
  --desired-count 5
```

### Infrastructure Updates

```bash
# Update Terraform configuration
vim terraform.tfvars

# Plan changes
terraform plan

# Apply updates
terraform apply
```

## 🗑️ Cleanup

To destroy all resources:

```bash
# Destroy everything
terraform destroy

# Confirm with 'yes'
```

⚠️ **Warning:** This will delete all resources including the database. Ensure you have backups if needed.

## 📚 Additional Resources

- [AWS ECS Fargate Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ECS Task Sizing](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Important Notes

- **Database Password**: Change the default RDS password immediately after deployment
- **Costs**: Monitor AWS costs regularly, especially NAT Gateway and data transfer
- **Backups**: Configure automated RDS snapshots (already enabled with 7-day retention)
- **Alerts**: Set up SNS topics for CloudWatch Alarms (not included, add if needed)
- **Domain**: Configure Route53 and SSL certificates for production domains

## 📞 Support

For issues or questions:
1. Check CloudWatch Logs
2. Review AWS ECS documentation
3. Open an issue in the repository
4. Contact your DevOps team

---

**Last Updated**: December 2025
**Terraform Version**: >= 1.0
**AWS Provider Version**: >= 5.0