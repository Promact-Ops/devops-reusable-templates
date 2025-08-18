# Variables for AWS infrastructure

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "promact-reusability-initiative"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "poc"
}

variable "owner" {
  description = "Team or person responsible for the resources"
  type        = string
  default     = "devops-team"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

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



# EC2 Variables
variable "use_custom_ami" {
  description = "Whether to use a custom AMI instead of latest Ubuntu"
  type        = bool
  default     = false
}

variable "ec2_ami" {
  description = "AMI ID for EC2 instance (used when use_custom_ami is true)"
  type        = string
  default     = ""
}

variable "ec2_instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.micro"
}

variable "ec2_root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "ec2_key_name" {
  description = "Name of the EC2 key pair for SSH access (REQUIRED)"
  type        = string
  
  validation {
    condition     = length(var.ec2_key_name) > 0
    error_message = "EC2 key pair name is required for SSH access. Please provide a valid key pair name."
  }
}

# RDS Variables
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
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage in GB for auto-scaling"
  type        = number
  default     = 100
}

variable "rds_db_name" {
  description = "Name of the database (only lowercase letters, numbers, and underscores allowed, no hyphens)"
  type        = string
  default     = "postgresqldb"
  
  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.rds_db_name))
    error_message = "RDS database name must contain only lowercase letters, numbers, and underscores. Hyphens are not allowed."
  }
}

variable "rds_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "rds_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!" # Change this in production
}

# Common Tags
variable "common_tags" {
  description = "Common tags for all resources (Project, Environment, and Owner will be auto-populated)"
  type        = map(string)
  default = {
    CreatedBy   = "terraform"
  }
}
