# Demo Ansible Playbook

Ansible playbook for provisioning an Ubuntu development machine.

## What's Included

- Mise (version manager for dev tools)
- Wezterm (terminal)
- Zsh (shell)
- Docker (via geerlingguy.docker role)
- Dev tools via mise (node, python, terraform)

## Quick Start

```bash
# Install dependencies
ansible-galaxy install -r requirements.yml

# Run the playbook
ansible-playbook main.yml -i inventory -K
```

## Configuration

Edit `config.yml` to customize:

- `mise_version` - Mise version to install
- `mise_tools` - Tools to install globally via mise
- `apt_packages` - APT packages to install

## Requirements

- Ansible 2.9+
- Ubuntu/Debian target
- Python 3 on target

## Inventory

Edit `inventory` to add hosts. Default includes localhost for testing.
