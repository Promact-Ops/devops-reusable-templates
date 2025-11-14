# ═══════════════════════════════════════════════════════════════════════════════
# Template 02 - ECS Infrastructure Configuration
# ═══════════════════════════════════════════════════════════════════════════════
# Copy this file to terraform.tfvars and update with your values
# cp terraform.tfvars.example terraform.tfvars
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
# 🔧 GENERAL CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

project_name = "myapp"              # Your project name (lowercase, no spaces)
environment  = "dev"                # Environment: dev, staging, production
aws_region   = "us-east-1"          # AWS region to deploy resources

# ═══════════════════════════════════════════════════════════════════════════════
# 🌐 VPC CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

vpc_cidr             = "10.0.0.0/16"                      # VPC CIDR block
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]     # Public subnets (for ALB)
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]   # Private subnets (for ECS tasks, RDS)

# NAT Gateway Configuration
enable_nat_gateway  = true    # Enable NAT Gateway for private subnets
single_nat_gateway  = true    # Use single NAT Gateway (cost-effective) or one per AZ (high availability)

# ═══════════════════════════════════════════════════════════════════════════════
# 🐳 ECS CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# Launch Type: FARGATE (serverless), EC2 (manage instances), or BOTH (flexibility)
ecs_launch_type = "EC2"

# EC2 Configuration (only needed if launch_type is EC2 or BOTH)
ec2_instance_type    = "t3.micro"   # Instance type for ECS cluster
ec2_desired_capacity = 2            # Desired number of EC2 instances
ec2_min_size         = 1            # Minimum number of EC2 instances
ec2_max_size         = 4            # Maximum number of EC2 instances

# ═══════════════════════════════════════════════════════════════════════════════
# 📦 ECS TASK CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# Frontend Task Configuration
# CPU units: 256 (.25 vCPU), 512 (.5 vCPU), 1024 (1 vCPU), 2048 (2 vCPU), 4096 (4 vCPU)
frontend_task_cpu    = 256      # CPU units for frontend task
frontend_task_memory = 512      # Memory in MB (must be compatible with CPU)
frontend_desired_count = 1     # Number of frontend tasks to run

# Backend Task Configuration
backend_task_cpu    = 512       # CPU units for backend task
backend_task_memory = 1024      # Memory in MB (must be compatible with CPU)
backend_desired_count = 1       # Number of backend tasks to run

# Valid CPU and Memory Combinations for Fargate:
# CPU: 256  -> Memory: 512, 1024, 2048
# CPU: 512  -> Memory: 1024, 2048, 3072, 4096
# CPU: 1024 -> Memory: 2048, 3072, 4096, 5120, 6144, 7168, 8192
# CPU: 2048 -> Memory: 4096 to 16384 (1GB increments)
# CPU: 4096 -> Memory: 8192 to 30720 (1GB increments)

# ═══════════════════════════════════════════════════════════════════════════════
# 📈 AUTO SCALING CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

enable_autoscaling       = true    # Enable auto scaling for ECS services
target_cpu_utilization   = 70      # Target CPU utilization percentage

# Frontend Auto Scaling Limits
frontend_min_tasks = 1             # Minimum number of frontend tasks
frontend_max_tasks = 10            # Maximum number of frontend tasks

# Backend Auto Scaling Limits
backend_min_tasks = 1              # Minimum number of backend tasks
backend_max_tasks = 10             # Maximum number of backend tasks

# ═══════════════════════════════════════════════════════════════════════════════
# ⚖️ APPLICATION LOAD BALANCER CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# HTTPS Configuration (optional)
enable_https    = false            # Enable HTTPS listener
certificate_arn = ""               # ARN of SSL/TLS certificate (required if enable_https = true)

# Health Check Configuration
frontend_health_check_path = "/"          # Health check path for frontend
backend_health_check_path  = "/health"    # Health check path for backend
health_check_interval      = 30           # Health check interval in seconds
health_check_timeout       = 5            # Health check timeout in seconds
healthy_threshold          = 2            # Consecutive successful checks for healthy
unhealthy_threshold        = 3            # Consecutive failed checks for unhealthy

# ═══════════════════════════════════════════════════════════════════════════════
# 🗂️ ECR CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

enable_ecr_scanning       = true   # Enable vulnerability scanning on image push
ecr_image_retention_count = 10     # Number of images to retain

# ═══════════════════════════════════════════════════════════════════════════════
# 🗄️ RDS (DATABASE) CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# Database Instance Configuration
rds_engine_version      = "15.5"         # PostgreSQL version
rds_instance_class      = "db.t3.micro"  # Instance class (db.t3.micro, db.t3.small, db.t3.medium, etc.)
rds_allocated_storage   = 20             # Initial storage in GB
rds_max_allocated_storage = 100          # Maximum storage for auto-scaling

# Database Credentials and Settings
rds_database_name = "myappdb"            # Database name (alphanumeric, no hyphens)
rds_username      = "dbadmin"            # Master username
rds_password      = "ChangeMe123456!"    # Master password (min 8 chars, CHANGE THIS!) also it shold not contain @

# Backup Configuration
rds_backup_retention_period = 7                  # Days to retain backups (0 to disable)
rds_backup_window           = "03:00-04:00"      # Preferred backup window (UTC)
rds_maintenance_window      = "sun:04:00-sun:05:00"  # Preferred maintenance window (UTC)

# High Availability
rds_multi_az = false                     # Enable Multi-AZ deployment (production: true, dev: false)

# ⚠️ IMPORTANT NOTES:
# - Change rds_password to a strong password before deployment
# - For production, set rds_multi_az = true for high availability
# - Backup retention should be at least 7 days for production
# - Consider using AWS Secrets Manager for password management

# ═══════════════════════════════════════════════════════════════════════════════
# 🗂️ S3 (STORAGE) CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

s3_versioning_enabled     = true         # Enable object versioning
s3_encryption_algorithm   = "AES256"     # Encryption: AES256 or aws:kms
s3_lifecycle_glacier_days = 90           # Days before transitioning to Glacier
s3_lifecycle_expiration_days = 365       # Days before object expiration

# ═══════════════════════════════════════════════════════════════════════════════
# 📊 CLOUDWATCH CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

log_retention_days         = 7      # CloudWatch log retention (1, 3, 5, 7, 14, 30, 60, 90, etc.)
enable_container_insights  = true   # Enable Container Insights for ECS cluster

# ═══════════════════════════════════════════════════════════════════════════════
# 🔍 SERVICE DISCOVERY CONFIGURATION (Optional)
# ═══════════════════════════════════════════════════════════════════════════════

enable_service_discovery = false    # Enable AWS Cloud Map service discovery

# ═══════════════════════════════════════════════════════════════════════════════
# 🏷️ ADDITIONAL TAGS (Optional)
# ═══════════════════════════════════════════════════════════════════════════════

additional_tags = {
  # Owner       = "DevOps Team"
  # CostCenter  = "Engineering"
  # Compliance  = "HIPAA"
}

# ═══════════════════════════════════════════════════════════════════════════════
# 📋 CONFIGURATION TEMPLATES
# ═══════════════════════════════════════════════════════════════════════════════

# Development Environment Template:
# - ecs_launch_type = "FARGATE"
# - frontend_task_cpu = 256, frontend_task_memory = 512
# - backend_task_cpu = 512, backend_task_memory = 1024
# - rds_instance_class = "db.t3.micro"
# - rds_multi_az = false
# - single_nat_gateway = true

# Production Environment Template:
# - ecs_launch_type = "FARGATE" or "BOTH"
# - frontend_task_cpu = 512, frontend_task_memory = 1024
# - backend_task_cpu = 1024, backend_task_memory = 2048
# - rds_instance_class = "db.t3.small" or larger
# - rds_multi_az = true
# - single_nat_gateway = false
# - enable_https = true
# - rds_backup_retention_period = 30

# ═══════════════════════════════════════════════════════════════════════════════