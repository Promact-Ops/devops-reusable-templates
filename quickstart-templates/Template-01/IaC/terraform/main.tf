# Main Terraform configuration for AWS infrastructure
# This configuration creates VPC, S3, EC2, and RDS resources

# Data source for latest Ubuntu LTS AMI
# If this fails, run: aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu*" --query 'Images[?State==`available`].{ID:ImageId,Name:Name}' --output table
# Then set use_custom_ami = true and provide the AMI ID in terraform.tfvars
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]   # Official Ubuntu AMI owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Random provider for unique S3 bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 2  # This will generate a 4-digit hex number
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

# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  # Multi-AZ setup required for RDS subnet group
  azs             = [var.availability_zone, "${var.aws_region}b"]
  private_subnets = [var.private_subnet_cidr, var.second_private_subnet_cidr]
  public_subnets  = [var.public_subnet_cidr, var.second_public_subnet_cidr]

  enable_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}

# S3 Bucket Module
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "5.4.0"

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

# IAM Role for EC2 to access S3
resource "aws_iam_role" "ec2_s3_access" {
  name = "${var.project_name}-${var.environment}-ec2-s3-access-role"

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

# IAM Policy for S3 access
resource "aws_iam_policy" "s3_full_access" {
  name        = "${var.project_name}-${var.environment}-s3-full-access-policy"
  description = "Full access to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
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

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ec2_s3_policy" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = aws_iam_policy.s3_full_access.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_s3_access.name

  tags = local.common_tags
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = module.vpc.vpc_id

  # Allow SSH (port 22) for management
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (port 80) for web access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Backend (port 8080) for API access
  ingress {
    description = "Backend API"
    from_port   = 8080
    to_port     = 8080
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

# EC2 Instance
resource "aws_instance" "docker_host" {
  ami                    = var.use_custom_ami ? var.ec2_ami : data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Root volume encryption
  root_block_device {
    volume_size = var.ec2_root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash
              
              # Exit on any error
              set -e
              
              echo "Starting Docker installation on Ubuntu $(lsb_release -rs)..."
              
              # Update system packages
              apt-get update -y
              
              # Install required packages for Docker
              apt-get install -y \
                  apt-transport-https \
                  ca-certificates \
                  curl \
                  gnupg \
                  lsb-release \
                  software-properties-common
              
              # Remove any old Docker installations
              apt-get remove -y docker docker-engine docker.io containerd runc || true
              
              # Add Docker's official GPG key
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              
              # Add Docker repository (automatically detect Ubuntu version)
              echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
              
              # Update package index
              apt-get update -y
              
              # Install Docker Engine
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              
              # Start and enable Docker service
              systemctl start docker
              systemctl enable docker
              
              # Add ubuntu user to docker group
              usermod -aG docker ubuntu
              
              # Install Docker Compose standalone (as backup)
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # Create symlink for docker-compose
              ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
              
              # Wait a moment for Docker to fully start
              sleep 10
              
              # Verify Docker installation
              echo "Docker installation completed successfully!"
              echo "Docker version: $(docker --version)"
              echo "Docker Compose version: $(docker-compose --version)"
              echo "Docker service status: $(systemctl is-active docker)"
              
              # Test Docker functionality
              docker run --rm hello-world
              
              # Create project folder structure
              echo "Creating project folder structure..."
              PROJECT_FOLDER="_${var.project_name}-${var.environment}-server"
              mkdir -p /home/ubuntu/$PROJECT_FOLDER/frontend
              mkdir -p /home/ubuntu/$PROJECT_FOLDER/backend
              
              # Set proper ownership and permissions
              chown -R ubuntu:ubuntu /home/ubuntu/$PROJECT_FOLDER
              chmod -R 755 /home/ubuntu/$PROJECT_FOLDER
              
              # Create docker-compose.yml directly with embedded template
              echo "Creating docker-compose.yml with embedded template..."
              cd /home/ubuntu/$PROJECT_FOLDER
              
              # Download docker-compose template from GitHub
              echo "Downloading docker-compose template from GitHub..."
              cd /home/ubuntu/$PROJECT_FOLDER
              curl -o docker-compose-template.yml https://raw.githubusercontent.com/Promact-Ops/devops-docker-templates/main/docker-compose-templates/docker-compose-Template-01.yml
              
              if [ -f "docker-compose-template.yml" ]; then
                echo "Template downloaded successfully. Customizing for project..."
                
                # Replace placeholders with actual values
                sed -i "s/\[PROJECTNAME_PH\]/${var.project_name}/g" docker-compose-template.yml
                sed -i "s/\[ENVIRONMENT_PH\]/${var.environment}/g" docker-compose-template.yml
                
                # Create the final docker-compose.yml
                mv docker-compose-template.yml docker-compose.yml
                
                echo "✅ Docker Compose file customized and created:"
                echo "  - Project Name: ${var.project_name}"
                echo "  - Environment: ${var.environment}"
                echo "  - File: /home/ubuntu/$PROJECT_FOLDER/docker-compose.yml"
                
                # Show the customized content
                echo "Customized docker-compose.yml content:"
                cat docker-compose.yml
              else
                echo "⚠️  Warning: Failed to download docker-compose template"
                echo "You may need to manually create docker-compose.yml"
              fi
              
              echo "✅ Docker Compose file customized and created:"
              echo "  - Project Name: ${var.project_name}"
              echo "  - Environment: ${var.environment}"
              echo "  - File: /home/ubuntu/$PROJECT_FOLDER/docker-compose.yml"
              
              # Show the customized content
              echo "Customized docker-compose.yml content:"
              cat docker-compose.yml
              
              echo "Project folders created:"
              echo "  - /home/ubuntu/$PROJECT_FOLDER/"
              echo "  - /home/ubuntu/$PROJECT_FOLDER/frontend/"
              echo "  - /home/ubuntu/$PROJECT_FOLDER/backend/"
              echo "  - /home/ubuntu/$PROJECT_FOLDER/docker-compose.yml"
              
              echo "=========================================="
              echo "✅ Docker Setup Completed Successfully!"
              echo "=========================================="
              echo "Docker Engine and Docker Compose are now available"
              echo "Project folder structure created in /home/ubuntu/$PROJECT_FOLDER/"
              echo "Docker Compose file customized for your project"
              echo "You can now run Docker commands as the ubuntu user"
              echo "Happy containerizing! 🐳"
              EOF

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-web-server"
  })
}

# Elastic IP for EC2 instance
resource "aws_eip" "ec2_eip" {
  domain = "vpc"
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-eip"
  })
}

# Associate Elastic IP with EC2 instance
resource "aws_eip_association" "ec2_eip_assoc" {
  instance_id   = aws_instance.docker_host.id
  allocation_id = aws_eip.ec2_eip.id
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = module.vpc.vpc_id

  # Allow PostgreSQL from EC2 security group
  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  tags = local.common_tags
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-${var.environment}-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = local.common_tags
}

# RDS Instance
resource "aws_db_instance" "postgresql" {
  identifier = "${var.project_name}-${var.environment}-postgresql"

  # Engine configuration
  engine               = "postgres"
  engine_version       = var.use_custom_db_version ? var.rds_engine_version : data.aws_rds_engine_version.postgresql.version
  instance_class       = var.rds_instance_class

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
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Performance insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  # Deletion protection
  deletion_protection = false

  # Snapshot configuration for destroy
  skip_final_snapshot = true

  tags = local.common_tags
}
