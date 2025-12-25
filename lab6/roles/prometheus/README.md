# Ansible Role: Prometheus

This role installs and configures Prometheus monitoring system on Ubuntu systems.

## Requirements

- Ubuntu 20.04 (Focal) or 22.04 (Jammy)
- Ansible 2.9+
- Internet connection to download Prometheus binaries

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
prometheus_version: "2.48.0"
prometheus_user: prometheus
prometheus_group: prometheus
prometheus_install_dir: /opt/prometheus
prometheus_config_dir: /etc/prometheus
prometheus_data_dir: /var/lib/prometheus
prometheus_port: 9090
prometheus_retention_time: "15d"

# Scrape targets configuration
prometheus_scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

# Alertmanager integration
alertmanager_enabled: true
alertmanager_url: 'http://localhost:9093'
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: monitoring
  become: yes
  roles:
    - role: prometheus
      vars:
        prometheus_scrape_configs:
          - job_name: 'prometheus'
            static_configs:
              - targets: ['localhost:9090']
          - job_name: 'node-exporter'
            static_configs:
              - targets: ['node1:9100', 'node2:9100']
```

## Testing with Molecule

This role includes Molecule tests. To run tests:

```bash
cd roles/prometheus
molecule test
```

## License

MIT

## Author Information

Created for Lab 6 - Monitoring Infrastructure.
