#!/bin/bash
# ECS instance user data script
# This script configures the EC2 instance to join the ECS cluster

# Configure ECS agent
echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_TASK_IAM_ROLE=true" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true" >> /etc/ecs/ecs.config

# Enable CloudWatch container insights (optional)
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config

# Set log level
echo "ECS_LOGLEVEL=info" >> /etc/ecs/ecs.config

# Restart ECS agent to apply configuration
systemctl restart ecs