# AWS ECS EC2 Infrastructure with Terraform

This Terraform configuration creates a complete AWS infrastructure for running containerized applications using **ECS with EC2 instances**. It includes VPC, S3, ECS Cluster with Auto Scaling Group, Application Load Balancer, and RDS PostgreSQL database.

## 🏗️ Architecture Overview

### Components Created

- **VPC**: Multi-AZ VPC with public and private subnets
- **ECS EC2 Cluster**: Container orchestration with EC2 instances
- **Auto Scaling Group**: Dynamic EC2 instance scaling
- **ECS Capacity Provider**: Managed scaling for containers and instances
- **Application Load Balancer**: HTTP/HTTPS traffic routing with dynamic port mapping
- **RDS PostgreSQL**: Managed database with encryption and backups
- **S3**: Encrypted bucket for application storage
- **ECR**: Container image repositories
- **CloudWatch**: Logging and monitoring with alarms
- **Secrets Manager**: Secure database password storage

### Network Architecture

```
Internet → ALB (Public Subnets) → EC2 Instances (Private Subnets) → RDS (Private Subnets)
                                         ↓
                                    ECS Tasks (Bridge Network)
                                         ↓
                                   NAT Gateway → Internet
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

# EC2 Instance Configuration
ecs_instance_type       = "t3.medium"  # or t3.large for more resources
ecs_instance_volume_size = 30

# Auto Scaling Group Configuration
ecs_desired_capacity = 2
ecs_min_size        = 1
ecs_max_size        = 10

# Capacity Provider Configuration
capacity_provider_target_capacity      = 80  # Target utilization %
capacity_provider_min_scaling_step_size = 1
capacity_provider_max_scaling_step_size = 10

# ECS Task Configuration
frontend_task_cpu     = "256"
frontend_task_memory  = "512"
backend_task_cpu      = "512"
backend_task_memory   = "1024"
frontend_desired_count = 2
backend_desired_count  = 2

# Service Auto Scaling
enable_service_autoscaling = true
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

### 1. **EC2-Based Container Hosting**
- Full control over instance types and configurations
- Direct SSH access via AWS Systems Manager Session Manager
- Predictable costs with Reserved Instances or Savings Plans
- Better for consistent, long-running workloads
- Support for GPU instances and specialized hardware

### 2. **Auto Scaling**
- **Instance Level**: ASG scales EC2 instances based on demand
- **Task Level**: ECS scales containers independently
- **Capacity Provider**: Coordinates scaling between tasks and instances
- Managed termination protection for graceful container draining

### 3. **Dynamic Port Mapping**
- Uses bridge networking mode
- Allows multiple tasks per instance
- Efficient resource utilization
- Automatic port assignment via ALB

### 4. **High Availability**
- Multi-AZ deployment
- Spread placement strategy across instances
- Binpack strategy for efficient resource usage
- Health checks and automatic task replacement
- ASG with scale-in protection

### 5. **Security**
- Private subnets for instances and database
- Security groups with least privilege
- Encrypted storage (S3, RDS, EBS)
- Secrets Manager for sensitive data
- SSM Session Manager for secure instance access
- VPC isolation

### 6. **Monitoring**
- CloudWatch Logs for all containers
- Container Insights enabled
- EC2 instance monitoring
- CloudWatch Alarms for:
  - RDS CPU, Memory, Storage
  - ALB response time and unhealthy targets
  - ECS CPU and Memory reservation
  - ASG metrics

## 🔧 Configuration Options

### Instance Type Selection

Choose instance types based on your workload:

| Instance Type | vCPUs | Memory | Best For |
|---------------|-------|---------|----------|
| t3.micro      | 2     | 1 GB    | Testing only |
| t3.small      | 2     | 2 GB    | Light workloads |
| t3.medium     | 2     | 4 GB    | Development |
| t3.large      | 2     | 8 GB    | Small production |
| m5.large      | 2     | 8 GB    | Balanced workloads |
| c5.large      | 2     | 4 GB    | CPU-intensive |
| r5.large      | 2     | 16 GB   | Memory-intensive |

### Task Placement on Instances

**Example**: t3.medium (2 vCPU, 4GB RAM) can run:
- 4x frontend tasks (256 CPU, 512MB each)
- 2x backend tasks (512 CPU, 1GB each)
- 1x frontend + 1x backend + overhead

### Environment-Specific Settings

**Development:**
```hcl
ecs_instance_type       = "t3.small"
ecs_desired_capacity    = 1
ecs_min_size           = 1
ecs_max_size           = 2
single_nat_gateway     = true
rds_multi_az          = false
enable_service_autoscaling = false
```

**Production:**
```hcl
ecs_instance_type       = "t3.large"  # or m5.large
ecs_desired_capacity    = 3
ecs_min_size           = 2
ecs_max_size           = 10
single_nat_gateway     = false
rds_multi_az          = true
enable_service_autoscaling = true
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

## 🖥️ Managing EC2 Instances

### Connect to Instances

```bash
# List EC2 instances
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=myapp-production-ecs-instance" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIpAddress]' \
  --output table

# Connect via Session Manager (no SSH key needed)
aws ssm start-session --target <instance-id>

# Once connected, view running containers
docker ps

# View ECS agent status
curl http://localhost:51678/v1/metadata
```

### Monitor Instance Health

```bash
# Check ASG status
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names myapp-production-ecs-asg

# View instance metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=<instance-id> \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

## 📈 Monitoring and Debugging

### View Logs

```bash
# Frontend logs
aws logs tail /ecs/myapp-production --follow --filter-pattern "frontend"

# Backend logs
aws logs tail /ecs/myapp-production --follow --filter-pattern "backend"

# View instance system logs
aws ec2 get-console-output --instance-id <instance-id>
```

### Check Service Status

```bash
# List services
aws ecs list-services --cluster myapp-production-cluster

# Describe service
aws ecs describe-services --cluster myapp-production-cluster --services myapp-production-frontend

# List tasks
aws ecs list-tasks --cluster myapp-production-cluster

# Describe task
aws ecs describe-tasks --cluster myapp-production-cluster --tasks <task-arn>
```

### Check Capacity Provider Status

```bash
# Describe capacity provider
aws ecs describe-capacity-providers \
  --capacity-providers myapp-production-capacity-provider

# View cluster capacity
aws ecs describe-clusters --clusters myapp-production-cluster
```

### Common Issues

**Tasks pending/not starting:**
- Check if ASG has launched instances: `aws autoscaling describe-auto-scaling-groups`
- Verify instances registered: `aws ecs list-container-instances --cluster myapp-production-cluster`
- Check instance CPU/Memory availability
- Review CloudWatch Logs for container errors

**Instances not joining cluster:**
- Verify ECS agent is running: `sudo systemctl status ecs`
- Check ECS config: `cat /etc/ecs/ecs.config`
- Verify IAM instance profile permissions
- Check NAT Gateway and internet connectivity

**Capacity provider not scaling:**
- Ensure ASG has `protect_from_scale_in = true`
- Check target capacity setting (default 80%)
- Review ECS cluster reservation metrics
- Verify managed scaling is enabled

**Database connection issues:**
- Verify security group allows traffic from ECS instances SG
- Check RDS endpoint in task environment variables
- Validate credentials in Secrets Manager

## 💰 Cost Estimation

**Monthly costs (approximate):**

| Service | Configuration | Est. Cost |
|---------|--------------|-----------|
| EC2 (2x t3.medium) | On-Demand 24/7 | ~$60 |
| EC2 (2x t3.medium) | Reserved 1-year | ~$35 |
| ALB | 1 ALB | ~$20 |
| NAT Gateway | 1 or 2 | ~$35-70 |
| RDS (db.t3.micro) | Single-AZ | ~$15 |
| RDS (db.t3.micro) | Multi-AZ | ~$30 |
| EBS Volumes (2x 30GB) | GP3 | ~$5 |
| Data Transfer | Varies | $10-50 |
| **Total (Dev)** | | **~$145** |
| **Total (Prod, On-Demand)** | | **~$180-210** |
| **Total (Prod, Reserved)** | | **~$155-185** |

**Cost optimization tips:**
- Use Reserved Instances or Savings Plans (up to 72% savings)
- Use Spot Instances for non-critical workloads (up to 90% savings)
- Right-size instances based on actual container needs
- Single NAT Gateway for dev environments
- Implement Auto Scaling to scale down during low traffic
- Use ASG scheduled scaling for predictable traffic patterns

## 🔄 Updates and Maintenance

### Update AMI (ECS-Optimized)

```bash
# The configuration automatically uses the latest ECS-optimized AMI
# To force update, modify launch template

terraform plan
terraform apply

# Gradually replace instances
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name myapp-production-ecs-asg
```

### Update Task Definitions

```bash
# After code changes and new image push
aws ecs update-service \
  --cluster myapp-production-cluster \
  --service myapp-production-frontend \
  --force-new-deployment
```

### Scaling Operations

```bash
# Scale ASG
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name myapp-production-ecs-asg \
  --desired-capacity 5

# Scale ECS service
aws ecs update-service \
  --cluster myapp-production-cluster \
  --service myapp-production-frontend \
  --desired-count 5
```

### Drain Instance for Maintenance

```bash
# Set instance to draining
aws ecs update-container-instances-state \
  --cluster myapp-production-cluster \
  --container-instances <container-instance-id> \
  --status DRAINING

# Wait for tasks to drain, then terminate
aws autoscaling terminate-instance-in-auto-scaling-group \
  --instance-id <instance-id> \
  --should-decrement-desired-capacity
```

## 🔐 Security Best Practices

1. **Instance Access**
   - Use Session Manager instead of SSH (already configured)
   - No need to manage SSH keys
   - All sessions logged to CloudWatch

2. **Secrets Management**
   - Store RDS password in Secrets Manager (already configured)
   - Use AWS Systems Manager Parameter Store for app configs
   - Never commit secrets to version control

3. **Network Security**
   - Instances in private subnets
   - Security groups with minimal permissions
   - No public IP addresses on instances
   - Use VPC endpoints for AWS services (optional improvement)

4. **Instance Security**
   - Regularly update ECS-optimized AMI
   - Enable CloudWatch detailed monitoring
   - Use IMDSv2 for metadata access (already configured in ECS-optimized AMI)

5. **SSL/TLS**
   ```hcl
   enable_https = true
   certificate_arn = "arn:aws:acm:region:account:certificate/xxx"
   ```

## 🆚 ECS EC2 vs Fargate Comparison

| Feature | ECS EC2 | ECS Fargate |
|---------|---------|-------------|
| **Management** | Manage EC2 instances | Fully serverless |
| **Cost** | Lower for steady workloads | Pay per task |
| **Flexibility** | Full instance control | Limited customization |
| **Scaling** | Instance + Task scaling | Task-only scaling |
| **Startup Time** | Faster (if instances ready) | Slower (cold start) |
| **Networking** | Bridge/Host modes | awsvpc only |
| **Use Case** | Predictable workloads | Variable/spiky traffic |
| **Savings Plans** | Reserved Instances | Fargate pricing |

**Choose EC2 when:**
- You have steady, predictable workloads
- You need specific instance types (GPU, high memory)
- You want maximum cost optimization with Reserved Instances
- You need tighter packing of containers
- You require custom instance configurations

**Choose Fargate when:**
- You want zero infrastructure management
- You have variable or unpredictable traffic
- You prefer operational simplicity
- Your workloads are short-lived or batch-oriented

## 🗑️ Cleanup

To destroy all resources:

```bash
# Destroy everything
terraform destroy

# Confirm with 'yes'
```

⚠️ **Warning:** This will delete all resources including:
- EC2 instances in ASG
- All ECS tasks and services
- Database (ensure backups exist)
- Load balancer
- All other infrastructure

## 📚 Additional Resources

- [AWS ECS EC2 Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_instances.html)
- [ECS Capacity Providers](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html)
- [Auto Scaling Best Practices](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-best-practices.html)
- [ECS-Optimized AMI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

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
- **Costs**: Monitor AWS costs regularly, especially EC2 instances and data transfer
- **Backups**: Configure automated RDS snapshots (already enabled with 7-day retention)
- **AMI Updates**: Regularly update to latest ECS-optimized AMI for security patches
- **Alerts**: Set up SNS topics for CloudWatch Alarms (not included, add if needed)
- **Reserved Instances**: Consider purchasing for production to save 30-70% on compute
- **Instance Refresh**: Use ASG instance refresh for zero-downtime updates

## 📞 Support

For issues or questions:
1. Check CloudWatch Logs
2. Review AWS ECS and EC2 documentation
3. Connect to instances via Session Manager for debugging
4. Open an issue in the repository
5. Contact your DevOps team

---

**Last Updated**: December 2025
**Terraform Version**: >= 1.0
**AWS Provider Version**: >= 5.0
**ECS Launch Type**: EC2 with Auto Scaling Group