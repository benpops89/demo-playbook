# Demo Ansible Playbook

Ansible playbook for provisioning an Ubuntu development machine.

## Features

- **Mise** - Version manager for dev tools
- **Wezterm** - Modern terminal emulator
- **Zsh** - Shell with dotfiles integration
- **JetBrains Mono Nerd Font** - Programmer's font
- **Docker** - Container platform (via geerlingguy.docker role)
- **Dotfiles** - Cloned and symlinked from repo
- **Dev Tools** - Installed via mise

## Quick Start

### Option 1: Bootstrap Script (Recommended)

One-command setup:

```bash
curl -fsSL https://raw.githubusercontent.com/benpops89/demo-playbook/main/scripts/bootstrap.sh | sh
```

This will:
1. Check and install dependencies (git, python3)
2. Clone the repository
3. Install Ansible dependencies
4. Run the playbook

### Option 2: Manual Setup

```bash
# 1. Install dependencies
sudo apt update && sudo apt install -y git python3

# 2. Install Ansible
sudo apt install -y ansible-core

# 3. Clone the repository
git clone https://github.com/benpops89/demo-playbook.git
cd demo-playbook

# 4. Install Ansible dependencies
ansible-galaxy install -r requirements.yml

# 5. Run the playbook
ansible-playbook main.yml -i inventory -K
```

## How It Works Together

This playbook pairs with [demo-dots](https://github.com/benpops89/demo-dots) for a complete development environment:

| Playbook | Purpose |
|----------|---------|
| **demo-playbook** | Provisions the machine - installs tools, Docker, fonts |
| **demo-dots** | Configures the environment - shell, editor, terminal settings |

The demo-playbook:
- Installs mise, wezterm, zsh, JetBrains Mono font
- Clones demo-dots to `~/dotfiles`
- Symlinks dotfiles to your home directory

After provisioning, your development environment is ready to use!

## Configuration

All configuration is managed in `config.yml`.

### Mise

```yaml
mise_version: "v2026.3.9"
mise_sha256: "sha256:..."
```

Downloads and installs mise binary with SHA256 verification for idempotent runs.

### APT Packages

```yaml
apt_packages:
  - wezterm
  - zsh
```

Packages to install via APT. The playbook automatically adds the Wezterm repository first.

### Fonts

```yaml
jetbrains_mono_version: "3.4.0"
jetbrains_mono_sha256: "sha256:..."
```

Downloads JetBrains Mono Nerd Font with checksum verification.

### Dotfiles

```yaml
dotfiles_repo: "https://github.com/benpops89/demo-dots.git"
dotfiles_dir: "{{ ansible_user_dir }}/dotfiles"

dotfiles_symlinks:
  - .zshrc
  - .zshenv
  - .config/opencode
  - .config/nvim
  - .config/starship.toml
  - .config/tmux
  - .config/lazygit
  - .config/sheldon
  - .config/wezterm
```

Clones your dotfiles repo and creates symlinks to your home directory. These symlinks integrate with your shell, editor, and terminal configuration.

### Docker

```yaml
docker_users:
  - demo
```

Users to add to the docker group for container access.

## Project Structure

```
.
├── main.yml              # Main playbook
├── config.yml           # Configuration variables
├── inventory            # Hosts definition
├── ansible.cfg          # Ansible config
├── requirements.yml     # Galaxy roles/collections
├── tasks/
│   ├── apt.yml         # APT packages and repositories
│   ├── fonts.yml        # JetBrains Mono installation
│   ├── dotfiles.yml     # Dotfiles and symlinks
│   └── mise.yml         # Mise installation
└── scripts/
    └── bootstrap.sh      # One-command setup script
```

## Requirements

- Ubuntu/Debian target
- Python 3 on target

## License

MIT
