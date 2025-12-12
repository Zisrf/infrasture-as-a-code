# Ansible Role: Grafana

This role installs and configures Grafana with pre-configured datasources and dashboards for monitoring visualization.

## Requirements

- Ubuntu 20.04 (Focal) or 22.04 (Jammy)
- Ansible 2.9+
- Internet connection to download Grafana packages

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
grafana_version: "10.2.2"
grafana_port: 3000
grafana_admin_user: admin
grafana_admin_password: admin
grafana_domain: localhost

# Prometheus datasource
prometheus_url: "http://localhost:9090"
prometheus_datasource_name: "Prometheus"

# Loki datasource
loki_url: "http://localhost:3100"
loki_datasource_name: "Loki"
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: monitoring
  become: yes
  roles:
    - role: grafana
      vars:
        grafana_admin_password: "secure_password"
        prometheus_url: "http://prometheus.local:9090"
```

## Features

- Automatic datasource provisioning (Prometheus and Loki)
- Pre-configured Spring Boot application dashboard
- Dashboard auto-discovery from templates
- Secure admin password configuration

## Testing with Molecule

This role includes Molecule tests. To run tests:

```bash
cd roles/grafana
molecule test
```

## License

MIT

## Author Information

Created for Lab 6 - Monitoring Infrastructure.
