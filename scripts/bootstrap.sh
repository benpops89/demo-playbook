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

log_success() {
  printf "\n   %bBootstrap complete! %b\n\n" "$GREEN" "$NC"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

run_step() {
  echo "   ● $1..."
  eval "$3" >/dev/null 2>&1
  echo "   ✓ $2"
  echo ""
}

check_dependencies() {
  MISSING=""

  for dep in git python3 ansible-core; do
    if ! command_exists "$dep"; then
      MISSING="$MISSING $dep"
    fi
  done

  if [ -n "$MISSING" ]; then
    log_warn "Missing:$MISSING"
    sudo apt update >/dev/null 2>&1 && sudo apt install -y$MISSING >/dev/null 2>&1
  fi
}

setup_repo() {
  if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR" || exit 1
    git pull origin "$BRANCH" >/dev/null 2>&1
  else
    git clone -b "$BRANCH" "$REPO" "$INSTALL_DIR" >/dev/null 2>&1
    cd "$INSTALL_DIR" || exit 1
  fi
}

install_ansible_deps() {
  ansible-galaxy install -r requirements.yml >/dev/null 2>&1
}

main() {
  cat <<'EOF'

   ╔══════════════════════════════════════════════════╗
   ║                                                  ║
   ║       ██████╗ ██████╗ ██╗███████╗████████╗       ║
   ║       ██╔══██╗██╔══██╗██║██╔════╝╚══██╔══╝       ║
   ║       ██████╔╝██████╔╝██║█████╗     ██║          ║
   ║       ██╔═══╝ ██╔══██╗██║██╔══╝     ██║          ║
   ║       ██║     ██║  ██║██║██║        ██║          ║
   ║       ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝        ╚═╝          ║
   ║                                                  ║
   ║            Ansible Development Setup             ║
   ║                                                  ║
   ╚══════════════════════════════════════════════════╝

EOF

  run_step "Authenticating" "Authenticated" "sudo -v"
  run_step "Installing dependencies" "Installed dependencies" "check_dependencies"
  run_step "Setting up repository" "Set up repository" "setup_repo"
  run_step "Installing Ansible deps" "Installed Ansible deps" "install_ansible_deps"

  run_step "Running playbook" "Ran playbook" "ansible-playbook main.yml -i inventory"

  log_success
}

main "$@"
