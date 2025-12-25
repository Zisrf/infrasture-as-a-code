# Ansible Role: Loki

This role installs and configures Loki log aggregation system for centralized logging.

## Requirements

- Ubuntu 20.04 (Focal) or 22.04 (Jammy)
- Ansible 2.9+
- Internet connection to download Loki binaries

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
loki_version: "2.9.3"
loki_user: loki
loki_group: loki
loki_install_dir: /opt/loki
loki_config_dir: /etc/loki
loki_data_dir: /var/lib/loki
loki_port: 3100
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: monitoring
  become: yes
  roles:
    - role: loki
      vars:
        loki_port: 3100
```

## Features

- Local filesystem storage configuration
- BoltDB shipper for index management
- Configurable data retention
- Integration with Alertmanager for log-based alerts

## Testing with Molecule

This role includes Molecule tests. To run tests:

```bash
cd roles/loki
molecule test
```

## License

MIT

## Author Information

Created for Lab 6 - Monitoring Infrastructure.
