# Lab 4: OpenVPN Server with Ansible and Molecule

## Overview
This lab demonstrates how to write Molecule tests for Ansible roles by creating an OpenVPN server role.

## Project Structure
```
lab4/
├── openvpn_role/           # Ansible role for OpenVPN server
│   ├── defaults/           # Default variables
│   ├── handlers/           # Handlers for service management
│   ├── meta/              # Role metadata for Ansible Galaxy
│   ├── molecule/          # Molecule test scenarios
│   │   └── default/       # Default test scenario
│   ├── tasks/             # Main tasks
│   └── templates/         # Jinja2 templates
├── requirements.yml       # Ansible Galaxy role requirements
├── openvpn_final.yml     # Playbook to deploy OpenVPN
└── inventory.ini         # Inventory file
```

## Features
- Automated OpenVPN server installation and configuration
- PKI (Public Key Infrastructure) setup with EasyRSA
- Client certificate and key generation
- Automated `.ovpn` client configuration file generation
- Molecule tests for role validation

## Prerequisites
- Ansible 2.9+
- Docker (for Molecule tests)
- Molecule with Docker driver
- Ubuntu 20.04 (tested)

## Installation

1. Install required roles:
```bash
cd lab4
ansible-galaxy install -r requirements.yml
```

2. Run the playbook:
```bash
ansible-playbook -i inventory.ini openvpn_final.yml
```

## Configuration

Key variables (in `openvpn_role/defaults/main.yml`):
- `openvpn_port`: OpenVPN server port (default: 1194)
- `openvpn_protocol`: Protocol to use (default: udp)
- `openvpn_server_host`: Server hostname/IP for client configuration
- `openvpn_network`: VPN network address (default: 10.8.0.0)
- `ovpn_output_path`: Path to save client `.ovpn` file

## Testing with Molecule

Run Molecule tests:
```bash
cd openvpn_role
molecule test
```

Run individual test stages:
```bash
molecule create    # Create test instance
molecule converge  # Apply the role
molecule verify    # Run verification tests
molecule destroy   # Clean up
```

## Client Configuration

After running the playbook, you'll find `client1.ovpn` in the specified output path (default: `/etc/openvpn/client/`). 

To use it:
1. Copy `client1.ovpn` to your client machine
2. Import it into your OpenVPN client (OpenVPN GUI, NetworkManager, etc.)
3. Connect to the VPN server

## Fixes Applied

### Certificate Format Issue
**Problem**: The generated `.ovpn` file contained both human-readable certificate information and PEM-encoded certificates, causing OpenVPN clients to fail with:
```
Failed to import file. This profile requires additional files for successful import [inline], [inline], [inline], [inline].
```

**Solution**: Modified the role to extract only the PEM-encoded certificate portion (between `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE-----`) from the client certificate file, excluding the human-readable text that EasyRSA generates.

### Role Naming Consistency
**Problem**: Inconsistent role naming between `meta/main.yml` and `requirements.yml`.

**Solution**: Standardized the role name as `doul_sy.openvpn_server` across all configuration files.

## Troubleshooting

### OpenVPN client import fails
Ensure the `.ovpn` file only contains PEM-encoded certificates without extra text. The fix in this version addresses this issue.

### Connection fails
- Check firewall rules allow UDP/1194
- Verify IP forwarding is enabled: `sysctl net.ipv4.ip_forward`
- Check OpenVPN server logs: `journalctl -u openvpn@server`

## References
- [Habr: OpenVPN Setup](https://habr.com/ru/post/233971/)
- [VPN: просто о сложном](https://habr.com/ru/post/534250/)
- [Molecule Documentation](https://molecule.readthedocs.io/)
- [Ansible Role Testing with Molecule](https://habr.com/ru/post/437216/)
