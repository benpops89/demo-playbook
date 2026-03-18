#!/bin/sh

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
    printf "%b[INFO]%b %s\n" "$GREEN" "$NC" "$1"
}

log_warn() {
    printf "%b[WARN]%b %s\n" "$YELLOW" "$NC" "$1"
}

log_error() {
    printf "%b[ERROR]%b %s\n" "$RED" "$NC" "$1" >&2
}

error_exit() {
    log_error "$1"
    exit 1
}

log_step() {
    printf "%b[STEP]%b %s\n" "$BLUE" "$NC" "$1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check and install dependencies
check_dependencies() {
    log_step "Checking dependencies..."

    MISSING=""

    for dep in git python3; do
        if command_exists "$dep"; then
            log_info "$dep is installed"
        else
            log_warn "$dep is not installed"
            MISSING="$MISSING $dep"
        fi
    done

    if [ -n "$MISSING" ]; then
        log_info "Installing missing packages:$MISSING"
        sudo apt update && sudo apt install -y$MISSING
    fi

    if ! command_exists ansible-core; then
        log_warn "ansible-core is not installed"
        log_info "Installing ansible-core..."
        sudo apt update && sudo apt install -y ansible-core
    else
        log_info "ansible-core is installed"
    fi
}

# Clone or update repo
setup_repo() {
    log_step "Setting up repository..."

    if [ -d "$INSTALL_DIR" ]; then
        log_info "Repository already exists at $INSTALL_DIR"
        cd "$INSTALL_DIR" || exit 1
        log_info "Updating repository..."
        git pull origin "$BRANCH"
    else
        log_info "Cloning repository to $INSTALL_DIR..."
        git clone -b "$BRANCH" "$REPO" "$INSTALL_DIR"
        cd "$INSTALL_DIR" || exit 1
    fi
}

# Install Ansible dependencies
install_ansible_deps() {
    log_step "Installing Ansible dependencies..."
    ansible-galaxy install -r requirements.yml
}

# Run Ansible playbook
run_playbook() {
    log_step "Running Ansible playbook..."
    ansible-playbook main.yml -i inventory -K
}

# Main
main() {
    printf "\n========================================\n"
    printf "  Demo Playbook Bootstrap\n"
    printf "========================================\n"
    printf "\n"

    check_dependencies
    setup_repo
    install_ansible_deps
    run_playbook

    log_info "Bootstrap complete!"
}

main "$@"
