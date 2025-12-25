# Quick Start Guide - Lab 6

## One-Command Deployment

The easiest way to deploy the entire monitoring infrastructure:

```bash
cd lab6
./deploy.sh
```

This script will:
1. Start the virtual machines
2. Check connectivity
3. Deploy all monitoring components and the application
4. Display access URLs

## Manual Step-by-Step

### 1. Start Virtual Machines

```bash
vagrant up
```

Wait for VMs to boot (first time may take 5-10 minutes).

### 2. Verify Connectivity

```bash
ansible -i inventories/hosts.ini all -m ping
```

Expected output: Both hosts should respond with "pong".

### 3. Deploy Everything

```bash
ansible-playbook -i inventories/hosts.ini deploy.yml
```

This will take 10-15 minutes to:
- Install Java and Maven on app server
- Clone and build Spring Boot application
- Install Prometheus, Grafana, Loki, and Alertmanager on monitoring server
- Configure all services

### 4. Access Services

Open these URLs in your browser:

- **Grafana**: http://192.168.56.31:3000
  - Username: `admin`
  - Password: `admin`
  - Pre-configured dashboard: "Spring Boot Application Metrics"

- **Prometheus**: http://192.168.56.31:9090
  - Check targets: Status → Targets
  - View alerts: Alerts

- **Application**: http://192.168.56.30:8080
  - Metrics: http://192.168.56.30:8080/actuator/prometheus
  - Health: http://192.168.56.30:8080/actuator/health

- **Alertmanager**: http://192.168.56.31:9093

## Configure Email Alerts

1. Edit `group_vars/all.yml`:

```yaml
smtp_host: "smtp.gmail.com"
smtp_port: 587
smtp_from: "your-email@gmail.com"
smtp_to: "recipient@example.com"
smtp_username: "your-email@gmail.com"
smtp_password: "your-app-password"
```

2. For Gmail, create an App Password:
   - Go to Google Account → Security
   - Enable 2-Step Verification
   - Create App Password
   - Use that password in the config

3. Re-run deployment:

```bash
ansible-playbook -i inventories/hosts.ini deploy.yml --tags alertmanager
```

## Test Alerting

### Trigger a Test Alert

Stop the application to trigger "InstanceDown" alert:

```bash
vagrant ssh app
sudo systemctl stop spring-boot-app
```

Wait 2-3 minutes, then check Alertmanager: http://192.168.56.31:9093

You should see the alert and receive an email notification.

Restart the application:

```bash
sudo systemctl start spring-boot-app
```

## Common Commands

### Check Service Status

```bash
# On app server
vagrant ssh app
sudo systemctl status spring-boot-app

# On monitoring server
vagrant ssh monitoring
sudo systemctl status prometheus
sudo systemctl status grafana-server
sudo systemctl status alertmanager
sudo systemctl status loki
```

### View Logs

```bash
# Spring Boot application
vagrant ssh app
sudo journalctl -u spring-boot-app -f

# Prometheus
vagrant ssh monitoring
sudo journalctl -u prometheus -f
```

### Restart Services

```bash
# Restart monitoring services
ansible-playbook -i inventories/hosts.ini deploy.yml --tags monitoring

# Restart application
ansible-playbook -i inventories/hosts.ini deploy.yml --tags app
```

## Troubleshooting

### Windows/Git Bash Issues

If you encounter Python tracebacks when running `ansible` commands on Windows:

**Option 1: Use WSL (Recommended)**
1. Install WSL2 with Ubuntu
2. Install Ansible inside WSL: `sudo apt update && sudo apt install ansible`
3. Run all commands from WSL terminal

**Option 2: Manual Deployment**
Skip the `deploy.sh` script and run commands manually:

```bash
# 1. Start VMs
vagrant up

# 2. Test connectivity manually
vagrant ssh app -c "echo 'VM is ready'"
vagrant ssh monitoring -c "echo 'VM is ready'"

# 3. Run Ansible playbook
ansible-playbook -i inventories/hosts.ini deploy.yml
```

**Option 3: Fix Ansible on Git Bash**
If Ansible fails with Python errors on Windows:
- Install Ansible through pip: `pip install ansible`
- Ensure Python 3.8+ is in PATH
- Set: `export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3`

### Ansible Privilege Escalation Error

If you see errors like "Operation not permitted" when cloning git repository:

```
Failed to set permissions on the temporary files Ansible needs to create when becoming an unprivileged user
```

This is already fixed in the current version with `allow_world_readable_tmpfiles = True` in `ansible.cfg`. If you still encounter this:

1. Ensure you're using the latest ansible.cfg from the repository
2. Alternatively, set environment variable: `export ANSIBLE_ALLOW_WORLD_READABLE_TMPFILES=true`
3. Or run the playbook with: `ansible-playbook -i inventories/hosts.ini deploy.yml -e 'ansible_allow_world_readable_tmpfiles=true'`

### Application Won't Start

```bash
vagrant ssh app
sudo journalctl -u spring-boot-app -n 100
```

Common issues:
- Port 8080 already in use
- Java not installed correctly
- JAR file not found

### Prometheus Can't Scrape Metrics

1. Check if application is running: http://192.168.56.30:8080/actuator/health
2. Check Prometheus targets: http://192.168.56.31:9090/targets
3. Verify network connectivity:
   ```bash
   vagrant ssh monitoring
   curl http://192.168.56.30:8080/actuator/prometheus
   ```

### Grafana Dashboard Shows No Data

1. Check datasource configuration:
   - Grafana → Configuration → Data Sources
   - Test connection to Prometheus

2. Verify Prometheus has data:
   - Prometheus UI → Graph
   - Query: `up`

### Email Alerts Not Working

1. Check Alertmanager logs:
   ```bash
   vagrant ssh monitoring
   sudo journalctl -u alertmanager -f
   ```

2. Common issues:
   - Incorrect SMTP credentials
   - Gmail App Password not used
   - Firewall blocking SMTP port

## Clean Up

### Stop VMs (preserving state)

```bash
vagrant halt
```

### Destroy Everything

```bash
vagrant destroy -f
```

### Remove all generated files

```bash
rm -rf .vagrant/
```

## Next Steps

- Customize Grafana dashboards
- Add more alert rules in `roles/prometheus/templates/alert_rules.yml.j2`
- Configure Loki to collect application logs
- Add more scrape targets to Prometheus
- Explore Grafana query builder for custom visualizations

## Support

For issues or questions, refer to:
- Main README.md
- Individual role READMEs in `roles/*/README.md`
- Lab assignment documentation
