#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║           Hyprland Dotfiles Installer                                       ║
# ║           github.com/theinfinityglitch                                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Usage:
#   ./install.sh               — interactive full install
#   ./install.sh --packages    — only install packages
#   ./install.sh --symlink     — only symlink dotfiles
#   ./install.sh --extras      — only install rnd + vicinae extensions
#   ./install.sh --update      — re-pull rnd + vicinae extension repos
#   ./install.sh --list-backups
#   ./install.sh --restore <backup-name>
#   ./install.sh --yes         — skip all confirmations (non-interactive)

set -euo pipefail

# Colors
RESET="\033[0m"
BOLD="\033[1m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
DIM="\033[2m"

# Helpers
info()    { echo -e "${CYAN}  →${RESET} $*"; }
success() { echo -e "${GREEN}  ✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}  ⚠${RESET}  $*"; }
err()     { echo -e "${RED}  ✗${RESET} $*" >&2; }
die()     { err "$*"; exit 1; }

# Banner
banner() {
cat << 'EOF'

  ╔══════════════════════════════════════════════════════╗
  ║                                                      ║
  ║     Hyprland · Waybar · Vicinae · rnd                ║
  ║     Dotfiles Installer                               ║
  ║                                                      ║
  ╚══════════════════════════════════════════════════════╝

EOF
}

# Locate script root (always the dotfiles folder)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${DOTFILES_DIR}/scripts"

# Sanity checks
check_arch() {
    if ! command -v pacman &>/dev/null; then
        die "pacman not found — this installer targets Arch Linux only."
    fi
}

check_python() {
    if ! command -v python3 &>/dev/null; then
        die "python3 is required. Install with: sudo pacman -S python"
    fi
    local ver
    ver=$(python3 -c "import sys; print(sys.version_info >= (3,10))")
    if [[ "$ver" != "True" ]]; then
        die "Python 3.10+ required. Current: $(python3 --version)"
    fi
}

check_git() {
    if ! command -v git &>/dev/null; then
        warn "git not found — installing via pacman…"
        sudo pacman -S --noconfirm git
    fi
}

# Python script runner
# Passes DOTFILES_DIR via PYTHONPATH so scripts can import common.py
run_python() {
    local script="$1"; shift
    PYTHONPATH="${SCRIPTS_DIR}" python3 "${SCRIPTS_DIR}/${script}" "$@"
}

# Confirm helper
# confirm_step "message" → returns 0 (yes) or 1 (no).
# When SKIP_CONFIRM=1 always returns 0.
confirm_step() {
    local prompt="$1"
    if [[ "${SKIP_CONFIRM:-0}" == "1" ]]; then
        return 0
    fi
    echo -e "\n  ${BOLD}${YELLOW}?${RESET} ${prompt} [Y/n] \c"
    read -r reply
    reply="${reply:-y}"
    case "${reply,,}" in
        y|yes) return 0 ;;
        *)     return 1 ;;
    esac
}

# Steps
step_packages() {
    local extra_flags=()
    [[ "${SKIP_CONFIRM:-0}" == "1" ]] && extra_flags+=("--skip-confirm")
    run_python packages.py "${extra_flags[@]}"
}

step_symlink() {
    local extra_flags=()
    [[ "${SKIP_CONFIRM:-0}" == "1" ]] && extra_flags+=("--skip-backup")
    run_python symlink.py "${extra_flags[@]}"
}

step_extras() {
    local extra_flags=()
    [[ "${SKIP_CONFIRM:-0}" == "1" ]] && extra_flags+=("--skip-confirm")
    [[ "${DO_UPDATE:-0}"    == "1" ]] && extra_flags+=("--update")
    run_python extras.py "${extra_flags[@]}"
}

step_list_backups() {
    run_python symlink.py --list-backups
}

step_restore() {
    run_python symlink.py --restore "$1"
}

# Argument parsing
DO_PACKAGES=0
DO_SYMLINK=0
DO_EXTRAS=0
DO_UPDATE=0
DO_LIST_BACKUPS=0
RESTORE_NAME=""
SKIP_CONFIRM=0
FULL_INSTALL=1  # default when no flags given

while [[ $# -gt 0 ]]; do
    case "$1" in
        --packages)        DO_PACKAGES=1; FULL_INSTALL=0 ;;
        --symlink)         DO_SYMLINK=1;  FULL_INSTALL=0 ;;
        --extras)          DO_EXTRAS=1;   FULL_INSTALL=0 ;;
        --update)          DO_UPDATE=1;   DO_EXTRAS=1; FULL_INSTALL=0 ;;
        --list-backups)    DO_LIST_BACKUPS=1; FULL_INSTALL=0 ;;
        --restore)
            shift
            RESTORE_NAME="${1:-}"
            [[ -z "$RESTORE_NAME" ]] && die "--restore requires a backup name"
            FULL_INSTALL=0
            ;;
        --yes|-y)          SKIP_CONFIRM=1 ;;
        -h|--help)
            banner
            echo -e "  ${BOLD}Usage:${RESET}"
            echo    "    ./install.sh               Full interactive install"
            echo    "    ./install.sh --packages    Install packages only"
            echo    "    ./install.sh --symlink     Symlink dotfiles only"
            echo    "    ./install.sh --extras      Build rnd + vicinae extensions only"
            echo    "    ./install.sh --update      Update rnd + extension repos and rebuild"
            echo    "    ./install.sh --list-backups"
            echo    "    ./install.sh --restore <name>"
            echo    "    ./install.sh --yes         Non-interactive (auto-confirm all)"
            echo
            exit 0
            ;;
        *) die "Unknown argument: $1  (use --help)" ;;
    esac
    shift
done

# Main
export DOTFILES_DIR SKIP_CONFIRM DO_UPDATE

banner
check_arch
check_python
check_git

# Specific single-purpose flags
if [[ "${DO_LIST_BACKUPS}" == "1" ]]; then
    step_list_backups
    exit 0
fi

if [[ -n "${RESTORE_NAME}" ]]; then
    step_restore "${RESTORE_NAME}"
    exit 0
fi

# Full or selective run
if [[ "${FULL_INSTALL}" == "1" ]]; then
    echo -e "  ${BOLD}Dotfiles dir:${RESET} ${DOTFILES_DIR}"
    echo

    # In full-install mode every step is gated by a confirmation.
    if confirm_step "Step 1/3 — Install pacman + AUR packages?"; then
        step_packages
    else
        warn "Skipping package installation."
    fi

    if confirm_step "Step 2/3 — Symlink dotfiles to ~/.config?"; then
        step_symlink
    else
        warn "Skipping symlinks."
    fi

    if confirm_step "Step 3/3 — Build rnd and vicinae extensions?"; then
        step_extras
    else
        warn "Skipping extras."
    fi
else
    # Selective flags: user explicitly asked for these, so just run them.
    [[ "${DO_PACKAGES}" == "1" ]] && step_packages
    [[ "${DO_SYMLINK}"  == "1" ]] && step_symlink
    [[ "${DO_EXTRAS}"   == "1" ]] && step_extras
fi

echo
echo -e "  ${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${BOLD}${GREEN}  All done! Log out and back in (or reboot) to apply.${RESET}"
echo -e "  ${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo