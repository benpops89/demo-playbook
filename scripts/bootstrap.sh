#!/usr/bin/env bash

set -euo pipefail

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Config
REPO="https://github.com/benpops89/demo-playbook.git"
BRANCH="main"
INSTALL_DIR="$HOME/demo-playbook"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

error_exit() {
    log_error "$1"
    exit 1
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check and install dependencies
check_dependencies() {
    log_step "Checking dependencies..."

    local deps=("git" "python3")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing+=("$dep")
        else
            log_info "$dep is installed"
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        log_warn "Missing dependencies: ${missing[*]}"
        log_info "Installing missing packages..."

        if [ "$(id -u)" -ne 0 ]; then
            error_exit "Please run with sudo to install packages"
        fi

        apt update
        apt install -y "${missing[@]}"
    fi

    if ! command_exists ansible-core; then
        log_warn "ansible-core is not installed"
        log_info "Installing ansible-core..."

        if [ "$(id -u)" -ne 0 ]; then
            error_exit "Please run with sudo to install ansible-core"
        fi

        apt update
        apt install -y ansible-core
    else
        log_info "ansible-core is installed"
    fi
}

# Clone or update repo
setup_repo() {
    log_step "Setting up repository..."

    if [ -d "$INSTALL_DIR" ]; then
        log_info "Repository already exists at $INSTALL_DIR"
        cd "$INSTALL_DIR"
        log_info "Updating repository..."
        git pull origin "$BRANCH"
    else
        log_info "Cloning repository to $INSTALL_DIR..."
        git clone -b "$BRANCH" "$REPO" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    fi
}

# Install Ansible dependencies
install_ansible_deps() {
    log_step "Installing Ansible dependencies..."
    ansible-galaxy install -r requirements.yml
}

# Prompt for confirmation
prompt_confirm() {
    echo ""
    read -rp "Ready to run Ansible playbook? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping playbook run. You can run it later with:"
        echo "  cd $INSTALL_DIR && ansible-playbook main.yml -i inventory -K"
        exit 0
    fi
}

# Run Ansible playbook
run_playbook() {
    log_step "Running Ansible playbook..."
    ansible-playbook main.yml -i inventory -K
}

# Main
main() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Demo Playbook Bootstrap${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    if [ "$(id -u)" -eq 0 ]; then
        error_exit "Please run as a normal user, not root. sudo will be used when needed."
    fi

    check_dependencies
    setup_repo
    install_ansible_deps
    prompt_confirm
    run_playbook

    log_info "Bootstrap complete!"
}

main "$@"
