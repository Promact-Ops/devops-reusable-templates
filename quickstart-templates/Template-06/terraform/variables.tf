variable "vps_ip" {
  description = "The public IP address of the VPS"
  type        = string
  default     = "172.179.8.84"
}

variable "private_key_path" {
  description = "The path to the private key for SSH access to the VPS"
  type        = string
  default     = "./jaydeep-test_key.pem"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "my_project"
  
}

variable "environment" {
  description = "The deployment environment (e.g., development, staging, production)"
  type        = string
  default     = "development"
  
}