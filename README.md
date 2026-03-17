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

### Target Machine Setup

On the target Ubuntu machine:

```bash
# Install git
sudo apt update
sudo apt install -y git

# Install ansible-core
pip3 install ansible-core
```

Or use the official Ansible installation script:

```bash
curl https://raw.githubusercontent.com/ansible/ansible/devel/installation-setup.sh | bash
```

## Inventory

Edit `inventory` to add hosts. Default includes localhost for testing.
