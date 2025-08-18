output "github_secrets_setup_guide" {
  description = "Complete guide for setting up GitHub repository secrets and other deployment details"
  value = <<EOT

📝 STEP-BY-STEP SETUP:

**FOR FRONTEND REPOSITORY:**
1. Go to your Frontend GitHub repository
2. Click on "Settings" tab
3. Click on "Secrets and variables" → "Actions"
4. Create SECRETS first (click "New repository secret"):
   - SERVER_SSH_KEY
   - SERVER_HOST  
   - SERVER_USER
5. Create VARIABLES next (click "New repository variable"):
   - FRONTEND_PATH
   - DOCKER_COMPOSE_PATH
   - FRONTEND_APP_ENV

**FOR BACKEND REPOSITORY:**
6. Go to your Backend GitHub repository
7. Click on "Settings" tab
8. Click on "Secrets and variables" → "Actions"
9. Create SECRETS first (click "New repository secret"):
   - SERVER_SSH_KEY
   - SERVER_HOST  
   - SERVER_USER
10. Create VARIABLES next (click "New repository variable"):
    - BACKEND_PATH
    - DOCKER_COMPOSE_PATH
    - BACKEND_APP_ENV

🗄️ S3 STORAGE DETAILS:
----------------------
S3 Bucket Name: ${module.s3_bucket.s3_bucket_id}
S3 Bucket Domain: ${module.s3_bucket.s3_bucket_bucket_domain_name}

🌐 RDS DATABASE DETAILS:
------------------------
Endpoint: ${aws_db_instance.postgresql.endpoint}
Port: ${aws_db_instance.postgresql.port}
Engine Version: ${aws_db_instance.postgresql.engine_version}

==========================================
🚀 GITHUB REPOSITORY SECRETS & VARIABLES SETUP GUIDE
==========================================

📋 GITHUB SECRETS TO CREATE (3):

1️ SERVER_SSH_KEY
   Value: [Copy entire content of your .pem file]
   Purpose: SSH authentication to EC2 instance

2️ SERVER_HOST
   Value: ${aws_eip.ec2_eip.public_ip}
   Purpose: EC2 instance public IP address

3️ SERVER_USER
   Value: ubuntu
   Purpose: SSH username for EC2 instance

📋 GITHUB VARIABLES TO CREATE (6):

**FRONTEND REPOSITORY VARIABLES (3):**

1️ FRONTEND_PATH 
   Value: /home/ubuntu/_${var.project_name}-${var.environment}-server/frontend
   Purpose: Frontend application deployment path

2️ DOCKER_COMPOSE_PATH
   Value: /home/ubuntu/_${var.project_name}-${var.environment}-server
   Purpose: Docker Compose configuration directory

3️ FRONTEND_APP_ENV
   Value: NEXT_PUBLIC_ENVIRONMENT=development
   Purpose: You must need to add all application environment variables into this check below example.

**BACKEND REPOSITORY VARIABLES (3):**

4️ BACKEND_PATH
   Value: /home/ubuntu/_${var.project_name}-${var.environment}-server/backend
   Purpose: Backend application deployment path

5️ DOCKER_COMPOSE_PATH
   Value: /home/ubuntu/_${var.project_name}-${var.environment}-server
   Purpose: Docker Compose configuration directory

6️ BACKEND_APP_ENV
   Value: DB_STRING=postgresql//test.db.com
   Purpose: You must need to add all application environment variables into this check below example.

✅ Infrastructure Created!

Go back to the README file and start setting up the GitHub repository. Once that's done, use the URLs below to access the sample applications:

**Frontend URL**: http://${aws_eip.ec2_eip.public_ip}
**Backend URL**: http://${aws_eip.ec2_eip.public_ip}:8080
==========================================
EOT
}
