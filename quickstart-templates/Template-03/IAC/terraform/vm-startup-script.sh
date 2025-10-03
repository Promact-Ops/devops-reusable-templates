#!/bin/bash
set -e
# This script is used to install basic tools on the virtual machine

# Log startup script execution
echo "Starting VM initialization script"
sudo apt update -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt-get install docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker


# Install nginx
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default
sudo ln -s /etc/nginx/sites-available/* /etc/nginx/sites-enabled/

# Install certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Make directory for the app
mkdir -p /home/ubuntu/app

echo "VM initialization script completed successfully"