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
  printf "\n%bBootstrap complete!%b\n" "$GREEN" "$NC"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

show_steps() {
  cat > /tmp/bootstrap_steps << 'EOF'
   ○ Checking dependencies
   ○ Installing dependencies
   ○ Setting up repository
   ○ Installing Ansible deps
   ○ Running playbook
EOF
  cat /tmp/bootstrap_steps
}

complete_step() {
  sed -i "s/○ $1/✓ $1/" /tmp/bootstrap_steps
  printf "\n"
  cat /tmp/bootstrap_steps
}

check_dependencies() {
  MISSING=""

  for dep in git python3; do
    if ! command_exists "$dep"; then
      MISSING="$MISSING $dep"
    fi
  done

  if ! command_exists ansible-core; then
    MISSING="$MISSING ansible-core"
  fi

  if [ -n "$MISSING" ]; then
    log_warn "Missing:$MISSING"
    install_dependencies "$MISSING"
  fi

  complete_step "Checking dependencies"
}

install_dependencies() {
  sudo apt update > /dev/null 2>&1 && sudo apt install -y$1 > /dev/null 2>&1
  complete_step "Installing dependencies"
}

setup_repo() {
  if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR" || exit 1
    git pull origin "$BRANCH" > /dev/null 2>&1
  else
    git clone -b "$BRANCH" "$REPO" "$INSTALL_DIR" > /dev/null 2>&1
    cd "$INSTALL_DIR" || exit 1
  fi
  
  complete_step "Setting up repository"
}

install_ansible_deps() {
  ansible-galaxy install -r requirements.yml > /dev/null 2>&1
  complete_step "Installing Ansible deps"
}

run_playbook() {
  ansible-playbook main.yml -i inventory -K > /dev/null 2>&1
  complete_step "Running playbook"
}

main() {
  cat <<'EOF'

   ╔══════════════════════════════════════════════════╗
   ║                                                  ║
   ║   ██████╗ ██████╗ ██╗███████╗████████╗          ║
   ║   ██╔══██╗██╔══██╗██║██╔════╝╚══██╔══╝          ║
   ║   ██████╔╝██████╔╝██║█████╗     ██║             ║
   ║   ██╔═══╝ ██╔══██╗██║██╔══╝     ██║             ║
   ║   ██║     ██║  ██║██║██║        ██║             ║
   ║   ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝        ╚═╝             ║
   ║                                                  ║
   ║        Ansible Development Setup                  ║
   ║                                                  ║
   ╚══════════════════════════════════════════════════╝

EOF

  echo ""
  show_steps
  check_dependencies
  setup_repo
  install_ansible_deps
  run_playbook

  printf "\n"
  log_success
}

main "$@"
