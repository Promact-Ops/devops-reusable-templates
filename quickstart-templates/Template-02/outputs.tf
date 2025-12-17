# Outputs for AWS ECS Infrastructure
# This file defines all output values after infrastructure deployment

# ═══════════════════════════════════════════════════════════════════════════════
# VPC OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

# ═══════════════════════════════════════════════════════════════════════════════
# ECS OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_frontend_service_name" {
  description = "Name of the frontend ECS service"
  value       = aws_ecs_service.frontend.name
}

output "ecs_backend_service_name" {
  description = "Name of the backend ECS service"
  value       = aws_ecs_service.backend.name
}

output "ecs_frontend_task_definition" {
  description = "Family name of the frontend task definition"
  value       = aws_ecs_task_definition.frontend.family
}

output "ecs_backend_task_definition" {
  description = "Family name of the backend task definition"
  value       = aws_ecs_task_definition.backend.family
}

# ═══════════════════════════════════════════════════════════════════════════════
# ECR OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_repository_name" {
  description = "Name of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.name
}

output "ecr_backend_repository_name" {
  description = "Name of the backend ECR repository"
  value       = aws_ecr_repository.backend.name
}

# ═══════════════════════════════════════════════════════════════════════════════
# LOAD BALANCER OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "frontend_target_group_arn" {
  description = "ARN of the frontend target group"
  value       = aws_lb_target_group.frontend.arn
}

output "backend_target_group_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.backend.arn
}

# ═══════════════════════════════════════════════════════════════════════════════
# RDS OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgresql.endpoint
}

output "rds_address" {
  description = "RDS instance address"
  value       = aws_db_instance.postgresql.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgresql.port
}

output "rds_database_name" {
  description = "Name of the database"
  value       = aws_db_instance.postgresql.db_name
}

output "rds_username" {
  description = "Master username for the database"
  value       = aws_db_instance.postgresql.username
  sensitive   = true
}

output "rds_password_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the RDS password"
  value       = aws_secretsmanager_secret.rds_password.arn
}

# ═══════════════════════════════════════════════════════════════════════════════
# S3 OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_region" {
  description = "Region of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_region
}

# ═══════════════════════════════════════════════════════════════════════════════
# IAM OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLOUDWATCH OUTPUTS
# ═══════════════════════════════════════════════════════════════════════════════

output "ecs_log_group_name" {
  description = "Name of the ECS CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_logs.name
}

# ═══════════════════════════════════════════════════════════════════════════════
# APPLICATION URLS
# ═══════════════════════════════════════════════════════════════════════════════

output "frontend_url" {
  description = "URL to access the frontend application"
  value       = "http://${aws_lb.main.dns_name}/"
}

output "backend_api_url" {
  description = "URL to access the backend API"
  value       = "http://${aws_lb.main.dns_name}/api"
}

output "backend_health_url" {
  description = "URL to check backend health"
  value       = "http://${aws_lb.main.dns_name}/health"
}

# ═══════════════════════════════════════════════════════════════════════════════
# GITHUB SECRETS SETUP GUIDE
# ═══════════════════════════════════════════════════════════════════════════════

output "github_secrets_setup_guide" {
  description = "Complete guide for setting up GitHub secrets and variables"
  sensitive   = true
  value       = <<-EOT
    
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                    GitHub Secrets and Variables Setup Guide                  ║
    ║                         Template 02 - ECS Deployment                          ║
    ╚══════════════════════════════════════════════════════════════════════════════╝

    📋 INFRASTRUCTURE DETAILS
    ═══════════════════════════════════════════════════════════════════════════════

    AWS Region:                 ${var.aws_region}
    Project Name:               ${var.project_name}
    Environment:                ${var.environment}
    ECS Cluster:                ${aws_ecs_cluster.main.name}

    ═══════════════════════════════════════════════════════════════════════════════
    🌐 APPLICATION ACCESS URLS
    ═══════════════════════════════════════════════════════════════════════════════

    Load Balancer DNS:          ${aws_lb.main.dns_name}
    Frontend URL:               http://${aws_lb.main.dns_name}/
    Backend API URL:            http://${aws_lb.main.dns_name}/api
    Backend Health Check:       http://${aws_lb.main.dns_name}/health

    ═══════════════════════════════════════════════════════════════════════════════
    🐳 CONTAINER REGISTRY (ECR)
    ═══════════════════════════════════════════════════════════════════════════════

    Frontend ECR Repository:    ${aws_ecr_repository.frontend.repository_url}
    Backend ECR Repository:     ${aws_ecr_repository.backend.repository_url}

    ═══════════════════════════════════════════════════════════════════════════════
    📊 ECS SERVICES
    ═══════════════════════════════════════════════════════════════════════════════

    Frontend Service:           ${aws_ecs_service.frontend.name}
    Backend Service:            ${aws_ecs_service.backend.name}
    Frontend Task Definition:   ${aws_ecs_task_definition.frontend.family}
    Backend Task Definition:    ${aws_ecs_task_definition.backend.family}

    ═══════════════════════════════════════════════════════════════════════════════
    🗄️ DATABASE (RDS)
    ═══════════════════════════════════════════════════════════════════════════════

    RDS Endpoint:               ${aws_db_instance.postgresql.endpoint}
    RDS Address:                ${aws_db_instance.postgresql.address}
    RDS Port:                   ${aws_db_instance.postgresql.port}
    Database Name:              ${aws_db_instance.postgresql.db_name}
    Database Username:          ${aws_db_instance.postgresql.username}
    Password Secret ARN:        ${aws_secretsmanager_secret.rds_password.arn}

    ═══════════════════════════════════════════════════════════════════════════════
    🗂️ STORAGE (S3)
    ═══════════════════════════════════════════════════════════════════════════════

    S3 Bucket Name:             ${module.s3_bucket.s3_bucket_id}
    S3 Bucket ARN:              ${module.s3_bucket.s3_bucket_arn}

    ═══════════════════════════════════════════════════════════════════════════════
    🔐 GITHUB SECRETS CONFIGURATION
    ═══════════════════════════════════════════════════════════════════════════════

    📝 FRONTEND REPOSITORY SECRETS (Settings → Secrets and variables → Actions)

    Create these 5 secrets:

    1. AWS_ACCOUNT_ID
       Value: [Your AWS Account ID - Get from AWS Console]

    2. AWS_REGION
       Value: ${var.aws_region}

    3. AWS_ACCESS_KEY_ID
       Value: [Your AWS Access Key ID]

    4. AWS_SECRET_ACCESS_KEY
       Value: [Your AWS Secret Access Key]

    5. RDS_PASSWORD
       Value: ${var.rds_password}

    ═══════════════════════════════════════════════════════════════════════════════
    📊 FRONTEND REPOSITORY VARIABLES (Settings → Secrets and variables → Actions)

    Create these 6 variables:

    1. ECR_FRONTEND_REPOSITORY
       Value: ${aws_ecr_repository.frontend.name}

    2. ECS_CLUSTER_NAME
       Value: ${aws_ecs_cluster.main.name}

    3. ECS_FRONTEND_SERVICE
       Value: ${aws_ecs_service.frontend.name}

    4. ECS_FRONTEND_TASK_DEFINITION
       Value: ${aws_ecs_task_definition.frontend.family}

    5. FRONTEND_APP_ENV
       Value: (Your frontend environment variables in JSON format)
       Example: {"NEXT_PUBLIC_API_URL":"http://${aws_lb.main.dns_name}/api"}

    6. S3_BUCKET_NAME
       Value: ${module.s3_bucket.s3_bucket_id}

    ═══════════════════════════════════════════════════════════════════════════════
    📝 BACKEND REPOSITORY SECRETS (Settings → Secrets and variables → Actions)

    Create these 5 secrets (same as frontend):

    1. AWS_ACCOUNT_ID
       Value: [Your AWS Account ID - Get from AWS Console]

    2. AWS_REGION
       Value: ${var.aws_region}

    3. AWS_ACCESS_KEY_ID
       Value: [Your AWS Access Key ID]

    4. AWS_SECRET_ACCESS_KEY
       Value: [Your AWS Secret Access Key]

    5. RDS_PASSWORD
       Value: ${var.rds_password}

    ═══════════════════════════════════════════════════════════════════════════════
    📊 BACKEND REPOSITORY VARIABLES (Settings → Secrets and variables → Actions)

    Create these 7 variables:

    1. ECR_BACKEND_REPOSITORY
       Value: ${aws_ecr_repository.backend.name}

    2. ECS_CLUSTER_NAME
       Value: ${aws_ecs_cluster.main.name}

    3. ECS_BACKEND_SERVICE
       Value: ${aws_ecs_service.backend.name}

    4. ECS_BACKEND_TASK_DEFINITION
       Value: ${aws_ecs_task_definition.backend.family}

    5. RDS_ENDPOINT
       Value: ${aws_db_instance.postgresql.address}

    6. RDS_DATABASE_NAME
       Value: ${aws_db_instance.postgresql.db_name}

    7. S3_BUCKET_NAME
       Value: ${module.s3_bucket.s3_bucket_id}

    ═══════════════════════════════════════════════════════════════════════════════
    📦 SAVE THESE CREDENTIALS SECURELY
    ═══════════════════════════════════════════════════════════════════════════════

    ⚠️ IMPORTANT: Save these details in a secure location before proceeding!

    Database Credentials:
    - Endpoint: ${aws_db_instance.postgresql.endpoint}
    - Database: ${aws_db_instance.postgresql.db_name}
    - Username: ${aws_db_instance.postgresql.username}
    - Password: ${var.rds_password}
    - Port: ${aws_db_instance.postgresql.port}

    AWS Account Details:
    - Account ID: [Get from AWS Console]
    - Region: ${var.aws_region}
    - Access Key ID: [From AWS IAM]
    - Secret Access Key: [From AWS IAM]

    ═══════════════════════════════════════════════════════════════════════════════
    📚 USEFUL COMMANDS
    ═══════════════════════════════════════════════════════════════════════════════

    # Get AWS Account ID
    aws sts get-caller-identity --query Account --output text

    # Login to ECR (Frontend)
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.frontend.repository_url}

    # Login to ECR (Backend)
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.backend.repository_url}

    # View ECS Service Status
    aws ecs describe-services --cluster ${aws_ecs_cluster.main.name} --services ${aws_ecs_service.frontend.name} ${aws_ecs_service.backend.name}

    # View ECS Tasks
    aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name}

    # View CloudWatch Logs
    aws logs tail ${aws_cloudwatch_log_group.ecs_logs.name} --follow

    ═══════════════════════════════════════════════════════════════════════════════

    🎉 Infrastructure deployment completed successfully!
    📖 Continue with Step 2 in the README to set up GitHub repositories.

    ═══════════════════════════════════════════════════════════════════════════════
  EOT
}

# ═══════════════════════════════════════════════════════════════════════════════
# QUICK REFERENCE
# ═══════════════════════════════════════════════════════════════════════════════

output "quick_reference" {
  description = "Quick reference for common values"
  value = {
    aws_region            = var.aws_region
    project_name          = var.project_name
    environment           = var.environment
    load_balancer_dns     = aws_lb.main.dns_name
    frontend_ecr_repo     = aws_ecr_repository.frontend.name
    backend_ecr_repo      = aws_ecr_repository.backend.name
    ecs_cluster_name      = aws_ecs_cluster.main.name
    frontend_service_name = aws_ecs_service.frontend.name
    backend_service_name  = aws_ecs_service.backend.name
    s3_bucket_name        = module.s3_bucket.s3_bucket_id
    rds_endpoint          = aws_db_instance.postgresql.address
    rds_database_name     = aws_db_instance.postgresql.db_name
  }
}