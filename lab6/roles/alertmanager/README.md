# Ansible Role: Alertmanager

This role installs and configures Alertmanager for handling alerts from Prometheus with email notifications.

## Requirements

- Ubuntu 20.04 (Focal) or 22.04 (Jammy)
- Ansible 2.9+
- Internet connection to download Alertmanager binaries
- SMTP server for email notifications

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
alertmanager_version: "0.26.0"
alertmanager_user: alertmanager
alertmanager_group: alertmanager
alertmanager_install_dir: /opt/alertmanager
alertmanager_config_dir: /etc/alertmanager
alertmanager_data_dir: /var/lib/alertmanager
alertmanager_port: 9093

# Email configuration for alerts
smtp_host: "smtp.gmail.com"
smtp_port: 587
smtp_from: "alerts@example.com"
smtp_to: "admin@example.com"
smtp_username: "alerts@example.com"
smtp_password: "changeme"
smtp_require_tls: true
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: monitoring
  become: yes
  roles:
    - role: alertmanager
      vars:
        smtp_host: "smtp.gmail.com"
        smtp_from: "alerts@mycompany.com"
        smtp_to: "admin@mycompany.com"
        smtp_username: "alerts@mycompany.com"
        smtp_password: "{{ vault_smtp_password }}"
```

## Testing with Molecule

This role includes Molecule tests. To run tests:

```bash
cd roles/alertmanager
molecule test
```

## License

MIT

## Author Information

Created for Lab 6 - Monitoring Infrastructure.
