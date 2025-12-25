#!/bin/bash

# Lab 6 Deployment Script
# This script automates the deployment of the monitoring infrastructure

set -e

echo "================================================"
echo "Lab 6: Monitoring Infrastructure Deployment"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Vagrant is installed
if ! command -v vagrant &> /dev/null; then
    echo -e "${RED}Error: Vagrant is not installed. Please install Vagrant first.${NC}"
    exit 1
fi

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo -e "${RED}Error: Ansible is not installed. Please install Ansible first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites check passed${NC}"
echo ""

# Step 1: Start VMs
echo "Step 1: Starting virtual machines..."
echo "This may take several minutes on first run..."
vagrant up

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to start virtual machines${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Virtual machines started successfully${NC}"
echo ""

# Wait for VMs to be ready
echo "Waiting for VMs to be ready..."
sleep 10

# Step 2: Check connectivity
echo "Step 2: Checking connectivity to VMs..."

# Try to ping VMs with better error handling
if ! ansible -i inventories/hosts.ini all -m ping 2>&1; then
    echo ""
    echo -e "${YELLOW}Warning: Ansible ping failed. This may be normal on Windows/Git Bash.${NC}"
    echo -e "${YELLOW}Attempting alternative connectivity test...${NC}"
    echo ""
    
    # Alternative test using vagrant ssh
    if vagrant ssh app -c "echo 'App VM is accessible'" && \
       vagrant ssh monitoring -c "echo 'Monitoring VM is accessible'"; then
        echo -e "${GREEN}✓ VMs are accessible via SSH${NC}"
        echo ""
        echo -e "${YELLOW}Note: If you're on Windows, consider using WSL for better Ansible compatibility.${NC}"
        echo -e "${YELLOW}Continuing with deployment...${NC}"
        echo ""
    else
        echo -e "${RED}Error: Cannot connect to VMs via SSH${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Connectivity check passed${NC}"
    echo ""
fi

# Step 3: Deploy monitoring stack
echo "Step 3: Deploying monitoring stack and application..."
ansible-playbook -i inventories/hosts.ini deploy.yml

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Deployment failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Deployment completed successfully${NC}"
echo ""

# Step 4: Display access information
echo "================================================"
echo "Deployment Summary"
echo "================================================"
echo ""
echo "Services are now available at:"
echo ""
echo -e "${GREEN}Application Server (192.168.56.30):${NC}"
echo "  - Spring Boot App: http://192.168.56.30:8080"
echo "  - Metrics Endpoint: http://192.168.56.30:8080/actuator/prometheus"
echo ""
echo -e "${GREEN}Monitoring Server (192.168.56.31):${NC}"
echo "  - Prometheus:    http://192.168.56.31:9090"
echo "  - Grafana:       http://192.168.56.31:3000 (admin/admin)"
echo "  - Alertmanager:  http://192.168.56.31:9093"
echo "  - Loki:          http://192.168.56.31:3100"
echo ""
echo -e "${YELLOW}Important:${NC}"
echo "  - Don't forget to configure email settings in group_vars/all.yml"
echo "  - Grafana dashboards are pre-configured and available"
echo "  - Alerting rules are active and monitoring your application"
echo ""
echo "================================================"
