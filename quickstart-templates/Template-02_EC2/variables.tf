# General Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

# ECS Configuration
variable "ecs_launch_type" {
  description = "ECS launch type (EC2, FARGATE, or BOTH)"
  type        = string
  default     = "FARGATE"
  validation {
    condition     = contains(["EC2", "FARGATE", "BOTH"], var.ecs_launch_type)
    error_message = "ECS launch type must be EC2, FARGATE, or BOTH"
  }
}

variable "ec2_instance_type" {
  description = "EC2 instance type for ECS cluster (if using EC2 launch type)"
  type        = string
  default     = "t3.micro"
}

variable "ec2_desired_capacity" {
  description = "Desired number of EC2 instances for ECS cluster"
  type        = number
  default     = 2
}

variable "ec2_min_size" {
  description = "Minimum number of EC2 instances for ECS cluster"
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "Maximum number of EC2 instances for ECS cluster"
  type        = number
  default     = 4
}

# ECS Task Configuration
variable "frontend_task_cpu" {
  description = "CPU units for frontend task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "frontend_task_memory" {
  description = "Memory for frontend task in MB"
  type        = number
  default     = 512
}

variable "backend_task_cpu" {
  description = "CPU units for backend task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512
}

variable "backend_task_memory" {
  description = "Memory for backend task in MB"
  type        = number
  default     = 1024
}

variable "frontend_desired_count" {
  description = "Desired number of frontend tasks"
  type        = number
  default     = 2
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 2
}

# Auto Scaling Configuration
variable "enable_autoscaling" {
  description = "Enable ECS service auto scaling"
  type        = bool
  default     = true
}

variable "frontend_min_tasks" {
  description = "Minimum number of frontend tasks"
  type        = number
  default     = 1
}

variable "frontend_max_tasks" {
  description = "Maximum number of frontend tasks"
  type        = number
  default     = 10
}

variable "backend_min_tasks" {
  description = "Minimum number of backend tasks"
  type        = number
  default     = 1
}

variable "backend_max_tasks" {
  description = "Maximum number of backend tasks"
  type        = number
  default     = 10
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70
}

# Application Load Balancer Configuration
variable "enable_https" {
  description = "Enable HTTPS listener on ALB"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of SSL certificate for HTTPS"
  type        = string
  default     = ""
}

variable "frontend_health_check_path" {
  description = "Health check path for frontend"
  type        = string
  default     = "/"
}

variable "backend_health_check_path" {
  description = "Health check path for backend"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

# ECR Configuration
variable "enable_ecr_scanning" {
  description = "Enable image scanning on ECR repositories"
  type        = bool
  default     = true
}

variable "ecr_image_retention_count" {
  description = "Number of images to retain in ECR"
  type        = number
  default     = 10
}

# RDS Configuration
variable "use_custom_db_version" {
  description = "Whether to use a custom PostgreSQL version instead of latest"
  type        = bool
  default     = false
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version (used when use_custom_db_version is true)"
  type        = string
  default     = "16.0"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Initial storage allocation in GB"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum storage for auto-scaling in GB"
  type        = number
  default     = 100
}

variable "rds_database_name" {
  description = "Name of the database to create"
  type        = string
}

variable "rds_username" {
  description = "Master username for database"
  type        = string
  default     = "dbadmin"
}

variable "rds_password" {
  description = "Master password for database (min 8 characters)"
  type        = string
  sensitive   = true
}

variable "rds_backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = false
}

variable "rds_backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "rds_maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

# S3 Configuration
variable "s3_versioning_enabled" {
  description = "Enable versioning for S3 bucket"
  type        = bool
  default     = true
}

variable "s3_encryption_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "s3_lifecycle_glacier_days" {
  description = "Days before transitioning to Glacier"
  type        = number
  default     = 90
}

variable "s3_lifecycle_expiration_days" {
  description = "Days before object expiration"
  type        = number
  default     = 365
}

# CloudWatch Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_container_insights" {
  description = "Enable Container Insights for ECS cluster"
  type        = bool
  default     = true
}

# Service Discovery Configuration
variable "enable_service_discovery" {
  description = "Enable AWS Cloud Map service discovery"
  type        = bool
  default     = false
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags for all resources (Project, Environment, and Owner will be auto-populated)"
  type        = map(string)
  default = {
    CreatedBy = "terraform"
  }
}

variable "owner" {
  description = "Team or person responsible for the resources"
  type        = string
  default     = "devops-team"
}

# VPC Variables
# variable "vpc_cidr" {
#   description = "CIDR block for VPC"
#   type        = string
#   default     = "10.0.0.0/16"
# }

variable "availability_zone" {
  description = "Availability zone for resources"
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "second_private_subnet_cidr" {
  description = "CIDR block for second private subnet (auto-calculated)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "second_public_subnet_cidr" {
  description = "CIDR block for second public subnet (auto-calculated)"
  type        = string
  default     = "10.0.4.0/24"
}

variable "rds_db_name" {
  description = "Name of the database (only lowercase letters, numbers, and underscores allowed, no hyphens)"
  type        = string
  default     = "postgresqldb"
}


#EC2 Variables
# Add these variables to your variables.tf file

# EC2 Instance Type for ECS
variable "ecs_instance_type" {
  description = "EC2 instance type for ECS cluster (when using EC2 launch type)"
  type        = string
  default     = "t3.medium"
}

# EC2 Instance Counts
variable "ecs_instance_desired_count" {
  description = "Desired number of EC2 instances in ECS cluster"
  type        = number
  default     = 2
}

variable "ecs_instance_min_count" {
  description = "Minimum number of EC2 instances in ECS cluster"
  type        = number
  default     = 1
}

variable "ecs_instance_max_count" {
  description = "Maximum number of EC2 instances in ECS cluster"
  type        = number
  default     = 4
}

variable "target_memory_utilization" {
  description = "Target memory utilization for autoscaling"
  type        = number
  default     = 75
}


# EC2 Instance Configuration

variable "ecs_instance_volume_size" {
  default = 30
}

# ASG Configuration
variable "ecs_desired_capacity" {
  default = 2
}

variable "ecs_min_size" {
  default = 1
}

variable "ecs_max_size" {
  default = 10
}

# Capacity Provider Configuration
variable "capacity_provider_target_capacity" {
  default = 80
}

variable "capacity_provider_min_scaling_step_size" {
  default = 1
}

variable "capacity_provider_max_scaling_step_size" {
  default = 10
}

# Service Auto Scaling
variable "enable_service_autoscaling" {
  default = true
}