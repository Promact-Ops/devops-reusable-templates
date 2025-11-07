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
echo "Adding Docker’s official GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -ofsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Determine Ubuntu codename automatically
UBUNTU_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

echo "Adding Docker repository for $UBUNTU_CODENAME..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null



# Update package index
apt-get update -y

# Install Docker Engine
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Add azureuser user to docker group
usermod -aG docker azureuser

# Install Docker Compose standalone (as backup)
curl -oL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
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
PROJECT_FOLDER="_${PROJECT_NAME}-${ENVIRONMENT}-server"
mkdir -p /home/ubuntu/$PROJECT_FOLDER/frontend
mkdir -p /home/ubuntu/$PROJECT_FOLDER/backend

# Set proper ownership and permissions
chown -R azureuser:azureuser /home/ubuntu/$PROJECT_FOLDER
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
sed -i "s/\[PROJECTNAME_PH\]/${PROJECT_NAME}/g" docker-compose-template.yml
sed -i "s/\[ENVIRONMENT_PH\]/${ENVIRONMENT}/g" docker-compose-template.yml

# Create the final docker-compose.yml
mv docker-compose-template.yml docker-compose.yml

echo "✅ Docker Compose file customized and created:"
echo "  - Project Name: ${PROJECT_NAME}"
echo "  - Environment: ${ENVIRONMENT}"
echo "  - File: /home/ubuntu/$PROJECT_FOLDER/docker-compose.yml"

# Show the customized content
echo "Customized docker-compose.yml content:"
cat docker-compose.yml
else
echo "⚠️  Warning: Failed to download docker-compose template"
echo "You may need to manually create docker-compose.yml"
fi

echo "✅ Docker Compose file customized and created:"
echo "  - Project Name: ${PROJECT_NAME}"
echo "  - Environment: ${ENVIRONMENT}"
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