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

# Progress tracking
TOTAL_STEPS=5
CURRENT_STEP=0
COMPLETED_STEPS=""

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

update_progress() {
  PERCENT=$(expr $CURRENT_STEP \* 100 / $TOTAL_STEPS)
  BAR_LEN=40
  FILLED=$(expr $PERCENT \* $BAR_LEN / 100)
  EMPTY=$(expr $BAR_LEN - $FILLED)
  
  printf "\r   [%*s" $FILLED "" | tr ' ' '='
  printf "%*s] %3d%%  %s" $EMPTY "" $PERCENT "$1"
}

log_step() {
  CURRENT_STEP=$(expr $CURRENT_STEP + 1)
  update_progress "$1"
}

add_completed() {
  COMPLETED_STEPS="${COMPLETED_STEPS}
   ${GREEN}✓${NC} $1"
}

show_summary() {
  printf "\n\n"
  echo "   ╔══════════════════════════════════════════════════╗"
  echo "   ║           Bootstrap Complete!                     ║"
  echo "   ╠══════════════════════════════════════════════════╣"
  echo "$COMPLETED_STEPS"
  echo "   ╚══════════════════════════════════════════════════╝"
  echo ""
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
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

  add_completed "Dependencies checked"
}

install_dependencies() {
  log_step "Installing dependencies..."
  sudo apt update && sudo apt install -y$1
  add_completed "Dependencies installed"
}

setup_repo() {
  if [ -d "$INSTALL_DIR" ]; then
    cd "$INSTALL_DIR" || exit 1
  else
    git clone -b "$BRANCH" "$REPO" "$INSTALL_DIR"
    cd "$INSTALL_DIR" || exit 1
  fi
  
  add_completed "Repository ready"
}

install_ansible_deps() {
  log_step "Installing Ansible deps..."
  ansible-galaxy install -r requirements.yml
  add_completed "Ansible deps ready"
}

run_playbook() {
  log_step "Running playbook..."
  ansible-playbook main.yml -i inventory -K
  add_completed "Playbook executed"
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
  check_dependencies
  setup_repo
  install_ansible_deps
  run_playbook

  show_summary
}

main "$@"
