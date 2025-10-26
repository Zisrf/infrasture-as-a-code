# Quick Start Guide

## Prerequisites
1. Ansible installed on your control machine
2. Vagrant installed on your control machine
3. VirtualBox or another Vagrant provider installed

## Step-by-Step Instructions

### 1. Download Vagrantfile
Download the Vagrantfile from the provided link and place it in this directory.

### 2. Start Vagrant VMs
```bash
vagrant up
```

This will create:
- app1 VM at 192.168.56.10
- db1 VM at 192.168.56.11

### 3. Verify SSH Keys
Ensure SSH private keys are generated at:
- `.vagrant/machines/app1/virtualbox/private_key`
- `.vagrant/machines/db1/virtualbox/private_key`

### 4. Test Connectivity
```bash
ansible -i inventory.ini all -m ping
```

Expected output:
```
app1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
db1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 5. Run Playbooks

#### Option 1: Run everything at once
```bash
ansible-playbook site.yml
```

#### Option 2: Run step-by-step
```bash
# Step 1: Install Docker on all hosts
ansible-playbook install_docker.yml

# Step 2: Deploy Django application on app hosts
ansible-playbook deploy_app.yml
```

### 6. Verify Deployment
Open browser and navigate to:
- http://192.168.56.10:8000

You should see the Django Local Library application.

## What Each Playbook Does

### site.yml
Main orchestration playbook that runs:
1. install_docker.yml - Installs Docker on all hosts
2. deploy_app.yml - Deploys Django app on [app] hosts

### install_docker.yml
- Updates apt cache
- Installs Docker dependencies
- Adds Docker repository
- Installs Docker CE
- Starts Docker service
- Adds vagrant user to docker group

### deploy_app.yml
- Installs git
- Clones django-locallibrary-tutorial repository
- Pulls timurbabs/django Docker image
- Runs Django container on port 8000

## Troubleshooting

### Issue: "Connection refused" or "Host unreachable"
**Solution**: Ensure Vagrant VMs are running:
```bash
vagrant status
```

### Issue: "Permission denied (publickey)"
**Solution**: Check SSH keys exist:
```bash
ls -la .vagrant/machines/*/virtualbox/private_key
```

### Issue: "Docker module not found"
**Solution**: Install Docker Python module on control machine:
```bash
pip install docker
```

### Issue: Container doesn't start
**Solution**: SSH into the VM and check Docker logs:
```bash
vagrant ssh app1
sudo docker logs django-app
```

## Advanced Usage

### View Inventory
```bash
ansible-inventory -i inventory.ini --list
```

### Run Specific Tasks
```bash
ansible-playbook deploy_app.yml --tags clone
```

### Check Mode (Dry Run)
```bash
ansible-playbook site.yml --check
```

### Verbose Output
```bash
ansible-playbook site.yml -v   # -v, -vv, -vvv, or -vvvv
```

## Cleanup

### Stop Application
```bash
ansible app -i inventory.ini -m docker_container -a "name=django-app state=stopped" --become
```

### Remove Container
```bash
ansible app -i inventory.ini -m docker_container -a "name=django-app state=absent" --become
```

### Destroy Vagrant VMs
```bash
vagrant destroy -f
```
