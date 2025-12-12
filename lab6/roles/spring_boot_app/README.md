# Ansible Role: Spring Boot Application

This role deploys the Spring Boot Demo application with Prometheus metrics exposure.

## Requirements

- Ubuntu 20.04 (Focal) or 22.04 (Jammy)
- Ansible 2.9+
- Internet connection to clone repository and download dependencies
- Sufficient memory for Java application (minimum 1GB)

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
app_name: "spring-boot-demo"
app_port: 8080
app_user: springboot
app_group: springboot
app_dir: /opt/spring-boot-app
app_git_repo: "https://github.com/grafana/spring-boot-demo.git"
app_git_version: "main"

# Java configuration
java_version: "17"
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: app
  become: yes
  roles:
    - role: spring_boot_app
      vars:
        app_port: 8080
        java_version: "17"
```

## Features

- Automatic Git repository cloning
- Maven build automation
- Systemd service configuration
- Prometheus metrics exposure at `/actuator/prometheus`
- Health check endpoint at `/actuator/health`
- Application logging configuration

## Exposed Endpoints

After deployment, the following endpoints are available:

- Application: `http://hostname:8080`
- Health Check: `http://hostname:8080/actuator/health`
- Prometheus Metrics: `http://hostname:8080/actuator/prometheus`
- Application Info: `http://hostname:8080/actuator/info`

## Testing with Molecule

This role includes Molecule tests. To run tests:

```bash
cd roles/spring_boot_app
molecule test
```

## License

MIT

## Author Information

Created for Lab 6 - Monitoring Infrastructure.
