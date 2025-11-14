# Main Terraform configuration for AWS ECS infrastructure
# This configuration creates VPC, S3, ECS (Fargate), ALB, and RDS resources

# Random provider for unique S3 bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 2 # This will generate a 4-digit hex number
}

# Local values for common tags
locals {
  common_tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  })
}

# Data source for latest PostgreSQL engine version
data "aws_rds_engine_version" "postgresql" {
  engine = "postgres"
}

# Data source for ECS-optimized AMI (if using EC2 launch type)
data "aws_ami" "ecs_optimized" {
  count       = var.ecs_launch_type == "EC2" || var.ecs_launch_type == "BOTH" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
# VPC MODULE
# ═══════════════════════════════════════════════════════════════════════════════

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  # Multi-AZ setup required for high availability
  azs             = [var.availability_zone, "${var.aws_region}b"]
  private_subnets = [var.private_subnet_cidr, var.second_private_subnet_cidr]
  public_subnets  = [var.public_subnet_cidr, var.second_public_subnet_cidr]

  # Enable NAT Gateway for private subnets (required for ECS Fargate to pull images)
  enable_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# S3 BUCKET MODULE
# ═══════════════════════════════════════════════════════════════════════════════

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.2"

  bucket = "${var.project_name}-${var.environment}-${random_id.bucket_suffix.hex}"

  # Block public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Server-side encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # Versioning
  versioning = {
    enabled = true
  }

  tags = local.common_tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECURITY GROUPS
# ═══════════════════════════════════════════════════════════════════════════════

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  # Allow HTTP from anywhere
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.project_name}-${var.environment}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  # Allow Frontend port from ALB
  ingress {
    description     = "Frontend from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow Backend port from ALB
  ingress {
    description     = "Backend from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow ECS tasks to communicate with each other
  ingress {
    description = "Inter-task communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = module.vpc.vpc_id

  # Allow PostgreSQL from ECS tasks
  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }

  tags = local.common_tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# IAM ROLES AND POLICIES
# ═══════════════════════════════════════════════════════════════════════════════

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for Secrets Manager access
resource "aws_iam_role_policy" "ecs_task_execution_secrets_policy" {
  name = "${var.project_name}-${var.environment}-ecs-secrets-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.rds_password.arn
      }
    ]
  })
}

# ECS Task Role (for application access to AWS services)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Policy for S3 access from ECS tasks
resource "aws_iam_policy" "ecs_s3_access_policy" {
  name        = "${var.project_name}-${var.environment}-ecs-s3-access-policy"
  description = "Policy for ECS tasks to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.s3_bucket.s3_bucket_arn,
          "${module.s3_bucket.s3_bucket_arn}/*"
        ]
      }
    ]
  })

  tags = local.common_tags
}

# Attach S3 policy to ECS task role
resource "aws_iam_role_policy_attachment" "ecs_task_s3_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_s3_access_policy.arn
}

# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring_role" {
  name = "${var.project_name}-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ═══════════════════════════════════════════════════════════════════════════════
# ECR REPOSITORIES
# ═══════════════════════════════════════════════════════════════════════════════

# ECR Repository for Frontend
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-${var.environment}-frontend"
  image_tag_mutability = "MUTABLE"


  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.common_tags
}

# ECR Repository for Backend
resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-${var.environment}-backend"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.common_tags
}

# # Lifecycle policy for Frontend ECR
# resource "aws_ecr_lifecycle_policy" "frontend_policy" {
#   repository = aws_ecr_repository.frontend.name

#   policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1
#         description  = "Keep last ${var.ecr_image_retention_count} images"
#         selection = {
#           tagStatus     = "tagged"
#           tagPrefixList = ["v"]
#           countType     = "imageCountMoreThan"
#           countNumber   = var.ecr_image_retention_count
#         }
#         action = {
#           type = "expire"
#         }
#       },
#       {
#         rulePriority = 2
#         description  = "Delete untagged images older than 7 days"
#         selection = {
#           tagStatus   = "untagged"
#           countType   = "sinceImagePushed"
#           countUnit   = "days"
#           countNumber = 7
#         }
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })
# }

# Lifecycle policy for Backend ECR
# resource "aws_ecr_lifecycle_policy" "backend_policy" {
#   repository = aws_ecr_repository.backend.name

#   policy = jsonencode({
#     rules = [
#       {
#         rulePriority = 1
#         description  = "Keep last ${var.ecr_image_retention_count} images"
#         selection = {
#           tagStatus     = "tagged"
#           tagPrefixList = ["v"]
#           countType     = "imageCountMoreThan"
#           countNumber   = var.ecr_image_retention_count
#         }
#         action = {
#           type = "expire"
#         }
#       },
#       {
#         rulePriority = 2
#         description  = "Delete untagged images older than 7 days"
#         selection = {
#           tagStatus   = "untagged"
#           countType   = "sinceImagePushed"
#           countUnit   = "days"
#           countNumber = 7
#         }
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })
# }

# ═══════════════════════════════════════════════════════════════════════════════
# APPLICATION LOAD BALANCER
# ═══════════════════════════════════════════════════════════════════════════════

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection       = false
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = local.common_tags
}

# Target Group for Frontend
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-${var.environment}-fe-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.healthy_threshold
    interval            = var.health_check_interval
    matcher             = "200"
    path                = var.frontend_health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.unhealthy_threshold
  }

  deregistration_delay = 30

  tags = local.common_tags
}

# Target Group for Backend
resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-${var.environment}-be-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.healthy_threshold
    interval            = var.health_check_interval
    matcher             = "200"
    path                = var.backend_health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.unhealthy_threshold
  }

  deregistration_delay = 30

  tags = local.common_tags
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = var.enable_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.enable_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.enable_https ? [] : [1]
      content {
        target_group {
          arn = aws_lb_target_group.frontend.arn
        }
      }
    }
  }
}

# HTTPS Listener (optional)
resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Listener Rule for Backend API (HTTP)
resource "aws_lb_listener_rule" "backend_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# Listener Rule for Backend API (HTTPS)
resource "aws_lb_listener_rule" "backend_https" {
  count        = var.enable_https ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# Listener Rule for Backend Health Check (HTTP)
resource "aws_lb_listener_rule" "backend_health_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/health"]
    }
  }
}

# Listener Rule for Backend Health Check (HTTPS)
resource "aws_lb_listener_rule" "backend_health_https" {
  count        = var.enable_https ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/health"]
    }
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
# ECS CLUSTER AND SERVICES
# ═══════════════════════════════════════════════════════════════════════════════

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = local.common_tags
}

# Secrets Manager for RDS Password
resource "aws_secretsmanager_secret" "rds_password" {
  name                    = "${var.project_name}-${var.environment}-rds-password-${random_id.bucket_suffix.hex}"
  description             = "RDS database password for ${var.project_name}-${var.environment}"
  recovery_window_in_days = 7

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = var.rds_password
}

# Frontend Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-${var.environment}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = [var.ecs_launch_type]
  cpu                      = var.frontend_task_cpu
  memory                   = var.frontend_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "nginx:latest"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "API_URL"
          value = "http://${aws_lb.main.dns_name}/api"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "frontend"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = local.common_tags
}

# Backend Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-${var.environment}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = [var.ecs_launch_type]
  cpu                      = var.backend_task_cpu
  memory                   = var.backend_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "nginx:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgresql.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgresql.port)
        },
        {
          name  = "DB_NAME"
          value = var.rds_db_name
        },
        {
          name  = "DB_USER"
          value = var.rds_username
        },
        {
          name  = "S3_BUCKET"
          value = module.s3_bucket.s3_bucket_id
        }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_secretsmanager_secret.rds_password.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = local.common_tags
}

# Frontend ECS Service
# Frontend ECS Service (Updated)
resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-${var.environment}-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.frontend_desired_count

  # Use launch_type for Fargate, omit for EC2 (uses capacity provider)
  launch_type = var.ecs_launch_type == "FARGATE" ? "FARGATE" : null

  # For EC2, use capacity provider strategy instead
  dynamic "capacity_provider_strategy" {
    for_each = var.ecs_launch_type == "EC2" || var.ecs_launch_type == "BOTH" ? [1] : []
    content {
      capacity_provider = aws_ecs_capacity_provider.ec2_capacity_provider[0].name
      weight            = 1
      base              = 1
    }
  }

# ---------------------------
# FARGATE network config
# ---------------------------
dynamic "network_configuration" {
  for_each = var.ecs_launch_type == "FARGATE" ? [1] : []
  content {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false   # or true if you want public Fargate
  }
}

# ---------------------------
# EC2 network config
# ---------------------------
dynamic "network_configuration" {
  for_each = var.ecs_launch_type == "EC2" ? [1] : []
  content {
    subnets         = module.vpc.private_subnets   # recommended for EC2 tasks
    security_groups = [aws_security_group.ecs_instances_sg[0].id]
    # NOTE: No assign_public_ip here (EC2 does NOT support it)
  }
}

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_task_execution_policy,
    aws_ecs_cluster_capacity_providers.main
  ]

  tags = local.common_tags
}

# Backend ECS Service (Updated)
resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-${var.environment}-backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.backend_desired_count

  # Use launch_type for Fargate, omit for EC2 (uses capacity provider)
  launch_type = var.ecs_launch_type == "FARGATE" ? "FARGATE" : null

  # For EC2, use capacity provider strategy instead
  dynamic "capacity_provider_strategy" {
    for_each = var.ecs_launch_type == "EC2" || var.ecs_launch_type == "BOTH" ? [1] : []
    content {
      capacity_provider = aws_ecs_capacity_provider.ec2_capacity_provider[0].name
      weight            = 1
      base              = 1
    }
  }

# ---------------------------
# FARGATE network config
# ---------------------------
dynamic "network_configuration" {
  for_each = var.ecs_launch_type == "FARGATE" ? [1] : []
  content {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false   # or true if you want public Fargate
  }
}

# ---------------------------
# EC2 network config
# ---------------------------
dynamic "network_configuration" {
  for_each = var.ecs_launch_type == "EC2" ? [1] : []
  content {
    subnets         = module.vpc.private_subnets   # recommended for EC2 tasks
    security_groups = [aws_security_group.ecs_instances_sg[0].id]
    # NOTE: No assign_public_ip here (EC2 does NOT support it)
  }
}


  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8080
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_task_execution_policy,
    aws_ecs_cluster_capacity_providers.main
  ]

  tags = local.common_tags
}

# Auto Scaling for Frontend
resource "aws_appautoscaling_target" "frontend" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.frontend_max_tasks
  min_capacity       = var.frontend_min_tasks
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "frontend_cpu" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.project_name}-${var.environment}-frontend-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend[0].resource_id
  scalable_dimension = aws_appautoscaling_target.frontend[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.target_cpu_utilization

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Auto Scaling for Backend
resource "aws_appautoscaling_target" "backend" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.backend_max_tasks
  min_capacity       = var.backend_min_tasks
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "backend_cpu" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.project_name}-${var.environment}-backend-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend[0].resource_id
  scalable_dimension = aws_appautoscaling_target.backend[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.target_cpu_utilization

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
# RDS DATABASE
# ═══════════════════════════════════════════════════════════════════════════════

# RDS Subnet Group
# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name       = "${var.project_name}-${var.environment}-rds-subnet-group"


# Security Group for RDS
# resource "aws_security_group" "rds_sg" {
#   name        = "${var.project_name}-${var.environment}-rds-sg"
#   description = "Security group for RDS instance"
#   vpc_id      = module.vpc.vpc_id

#   # Allow PostgreSQL from EC2 security group
#   ingress {
#     description     = "PostgreSQL from EC2"
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ec2_sg.id]
#   }

#   tags = local.common_tags
# }

# # RDS Subnet Group
# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name       = "${var.project_name}-${var.environment}-rds-subnet-group"
#   subnet_ids = module.vpc.private_subnets

#   tags = local.common_tags
# }

# # RDS Instance
# resource "aws_db_instance" "postgresql" {
#   identifier = "${var.project_name}-${var.environment}-postgresql"

#   # Engine configuration
#   engine               = "postgres"
#   engine_version       = var.use_custom_db_version ? var.rds_engine_version : data.aws_rds_engine_version.postgresql.version
#   instance_class       = var.rds_instance_class

#   # Storage configuration
#   allocated_storage     = var.rds_allocated_storage
#   max_allocated_storage = var.rds_max_allocated_storage
#   storage_type          = "gp3"
#   storage_encrypted     = true

#   # Network configuration
#   db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
#   vpc_security_group_ids = [aws_security_group.rds_sg.id]
#   publicly_accessible    = false

#   # Database configuration
#   db_name  = var.rds_db_name
#   username = var.rds_username
#   password = var.rds_password

#   # Backup and maintenance
#   backup_retention_period = 7
#   backup_window          = "03:00-04:00"
#   maintenance_window     = "sun:04:00-sun:05:00"

#   # Performance insights
#   performance_insights_enabled = true
#   performance_insights_retention_period = 7

#   # Deletion protection
#   deletion_protection = false

#   # Snapshot configuration for destroy
#   skip_final_snapshot = true

#   tags = local.common_tags
# }

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-${var.environment}-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = local.common_tags
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-${var.environment}-db-params"
  family = "postgres17" # Adjust based on PostgreSQL version

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = local.common_tags
}

# RDS Instance
resource "aws_db_instance" "postgresql" {
  identifier = "${var.project_name}-${var.environment}-postgresql"

  # Engine configuration
  engine         = "postgres"
  engine_version = var.use_custom_db_version ? var.rds_engine_version : data.aws_rds_engine_version.postgresql.version
  instance_class = var.rds_instance_class

  # Storage configuration
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false

  # Database configuration
  db_name  = var.rds_db_name
  username = var.rds_username
  password = var.rds_password

  # Backup and maintenance
  backup_retention_period = var.rds_backup_retention_period
  backup_window           = var.rds_backup_window
  maintenance_window      = var.rds_maintenance_window

  # Performance insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.rds_monitoring_role.arn

  # High Availability
  multi_az = var.rds_multi_az

  # Parameter Group
  parameter_group_name = aws_db_parameter_group.main.name

  # Deletion protection
  deletion_protection = false

  # Snapshot configuration
  skip_final_snapshot = true
  tags                = local.common_tags

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier
    ]
  }
}

# CloudWatch Alarms for RDS
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-database-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS CPU utilization"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgresql.id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "database_memory" {
  alarm_name          = "${var.project_name}-${var.environment}-database-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "268435456" # 256 MB
  alarm_description   = "This metric monitors RDS freeable memory"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgresql.id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "database_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-database-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "2147483648" # 2 GB
  alarm_description   = "This metric monitors RDS free storage space"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgresql.id
  }

  tags = local.common_tags
}

# Add these resources to your main.tf file for EC2 launch type support

# ═══════════════════════════════════════════════════════════════════════════════
# EC2 LAUNCH TYPE CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# IAM Role for EC2 instances
resource "aws_iam_role" "ecs_instance_role" {
  count = var.ecs_launch_type == "EC2" || var.ecs_launch_type == "BOTH" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach ECS policy to instance role
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  count      = var.ecs_launch_type == "EC2" || var.ecs_launch_type == "BOTH" ? 1 : 0
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  count = var.ecs_launch_type == "EC2" || var.ecs_launch_type == "BOTH" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ecs-instance-profile"
  role  = aws_iam_role.ecs_instance_role[0].name

  tags = local.common_tags
}

# Security Group for EC2 instances
resource "aws_security_group" "ecs_instances_sg" {
  count       = var.ecs_launch_type == "EC2" || var.ecs_launch_type == "BOTH" ? 1 : 0
  name        = "${var.project_name}-${var.environment}-ecs-instances-sg"
  description = "Security group for ECS EC2 instances"
  vpc_id      = module.vpc.vpc_id

  # Allow traffic from ALB
  ingress {
    description     = "Traffic from ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow instances to communicate with each other
  ingress {
    description = "Inter-instance communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# Launch Template for ECS instances
resource "aws_launch_template" "ecs_launch_template" {
  count         = var.ecs_launch_type == "EC2" || var.ecs_launch_type == "BOTH" ? 1 : 0
  name          = "${var.project_name}-${var.environment}-ecs-launch-template"
  image_id      = data.aws_ami.ecs_optimized[0].id
  instance_type = var.ecs_instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance_profile[0].arn
  }

  vpc_security_group_ids = [aws_security_group.ecs_instances_sg[0].id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = aws_ecs_cluster.main.name
  }))

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-ecs-instance"
      }
    )
  }

  tags = local.common_tags
}

# Auto Scaling Group for ECS instances
resource "aws_autoscaling_group" "ecs_asg" {
  count               = var.ecs_launch_type == "EC2" || var.ecs_launch_type == "BOTH" ? 1 : 0
  name                = "${var.project_name}-${var.environment}-ecs-asg"
  vpc_zone_identifier = module.vpc.public_subnets # Use public subnets since NAT is disabled
  desired_capacity    = var.ecs_instance_desired_count
  max_size            = var.ecs_instance_max_count
  min_size            = var.ecs_instance_min_count

  launch_template {
    id      = aws_launch_template.ecs_launch_template[0].id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-ecs-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  count = var.ecs_launch_type == "EC2" || var.ecs_launch_type == "BOTH" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg[0].arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }

  tags = local.common_tags
}

# Associate Capacity Provider with ECS Cluster
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = concat(
    var.ecs_launch_type == "FARGATE" ? ["FARGATE", "FARGATE_SPOT"] : [],
    var.ecs_launch_type == "EC2" ? [aws_ecs_capacity_provider.ec2_capacity_provider[0].name] : [],
    var.ecs_launch_type == "BOTH" ? ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.ec2_capacity_provider[0].name] : []
  )

  default_capacity_provider_strategy {
    capacity_provider = var.ecs_launch_type == "FARGATE" ? "FARGATE" : aws_ecs_capacity_provider.ec2_capacity_provider[0].name
    weight            = 1
    base              = 1
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
# UPDATED ECS SERVICES FOR EC2 SUPPORT
# ═══════════════════════════════════════════════════════════════════════════════

