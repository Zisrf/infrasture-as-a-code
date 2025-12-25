#!/bin/bash
# Verification script to check if you have the latest ansible.cfg and task files

echo "Checking Lab 6 configuration..."
echo ""

# Check if ansible.cfg has pipelining
if grep -q "pipelining = True" ansible.cfg; then
    echo "✓ ansible.cfg has pipelining enabled"
else
    echo "✗ ansible.cfg missing pipelining - PLEASE PULL LATEST CHANGES"
    exit 1
fi

# Check if git clone task doesn't have become_user pointing to app_user
if grep -A 6 "Clone Spring Boot" roles/spring_boot_app/tasks/main.yml | grep -q "become_user: root"; then
    echo "✓ Git clone task configured to run as root"
else
    echo "⚠ Git clone task configuration may need update"
fi

# Check if Set ownership task exists
if grep -q "Set ownership of cloned repository" roles/spring_boot_app/tasks/main.yml; then
    echo "✓ Ownership fix task is present"
else
    echo "✗ Ownership fix task missing - PLEASE PULL LATEST CHANGES"
    exit 1
fi

echo ""
echo "Configuration looks good! You can run:"
echo "  ansible-playbook -i inventories/hosts.ini deploy.yml"
