#!/usr/bin/env python3
"""
packages.py — Install pacman and AUR packages for the Hyprland dotfiles setup.

Usage:
    python3 scripts/packages.py [--aur-only] [--pacman-only] [--skip-confirm]
"""

import argparse
import sys
from common import (
    header, info, success, warn, error, die,
    confirm, run, command_exists,
)

# Package lists

# Official Arch repos (pacman -S)
PACMAN_PACKAGES = [
    # Hyprland ecosystem
    "hyprland",           # Tiling WM (includes Lua config support)
    "hypridle",           # Idle daemon
    "hyprlock",           # Screen locker
    "hyprpicker",         # Color picker (in extra repo now)
    "xdg-desktop-portal-hyprland",  # Screen share / portals

    # Status bar
    "playerctl",          # Media control for waybar custom/playerctl

    # Terminal / shell
    "kitty",
    "bash",

    # Apps
    "firefox",
    "spotify-launcher",
    "steam",
    "dolphin",            # File manage
    "ark",
    "fastfetch",          # System info
    "gnome-keyring",      # Secret storage
    "eza",
    "awww",
    "imagemagick",
    "archlinux-xdg-menu",
    "wf-recorder",
    "neovim",
    "vi",
    "vim",

    # GTK / theming
    "gtk4",
    "gtk3",
    "gtk4-layer-shell",
    "gnome-themes-extra",
    "nwg-look",           # GTK theme switcher for Wayland

    # QT / theming
    "breeze",
    "breeze5",

    # Fonts
    "nerd-fonts",
    "ttf-cascadia-code",

    # Runtimes / build tools
    "base-devel",
    "git",
    "github-cli",
    "nodejs",
    "npm",
    "rust",               # Provides cargo; prefer rustup if you want toolchain mgmt
    "lua-language-server",
    "tree-sitter-cli",
    "stylua",
    "prettier",
    "vscode-css-languageserver",
    "vscode-html-languageserver",
    "eslint-language-server",
    "vscode-json-languageserver",
    "typescript-language-server",

    # Session / polkit
    "polkit",
    "dbus",

    # Pipewire / audio
    "pipewire",
    "wireplumber",
    "pipewire-pulse",

    # Screen control
    "brightnessctl",

    # Bluetooth
    "bluez",
    "bluez-utils",
    "bluetui",
]

# AUR packages (built with yay / paru)
AUR_PACKAGES = [
    "wlogout",               # Logout screen
    "hyprpolkitagent",       # Hyprland polkit agent (/usr/lib/hyprpolkitagent/hyprpolkitagent)
    "grimblast",
    "vicinae-bin",           # App launcher used as $menu
    "zed",                   # Code editor
    "visual-studio-code-bin",
    "qt5ct-kde",
    "qt6ct-kde",
    "vesktop-bin",
    "waybar-git",
    "netcoredbg-bin",
    "zls-bin",
    "quickshell-git",
]

# AUR helper detection / bootstrap

def detect_aur_helper() -> str | None:
    """Return the first available AUR helper, or None."""
    for helper in ("yay", "paru"):
        if command_exists(helper):
            return helper
    return None

def install_yay() -> None:
    """Bootstrap yay from the AUR."""
    info("Installing yay (AUR helper)…")
    cmds = [
        "git clone https://aur.archlinux.org/yay.git /tmp/yay-install",
        "cd /tmp/yay-install && makepkg -si --noconfirm",
        "rm -rf /tmp/yay-install",
    ]
    for cmd in cmds:
        try:
            from common import run_shell
            run_shell(cmd)
        except Exception as exc:
            die(f"Failed to install yay: {exc}")
    success("yay installed.")

# Installation helpers

def pacman_install(packages: list[str], skip_confirm: bool) -> None:
    """Install packages with pacman, skipping already-installed ones."""
    info("Checking which packages are already installed…")

    to_install = []
    for pkg in packages:
        result = run(["pacman", "-Q", pkg], check=False, capture=True)
        if result.returncode != 0:
            to_install.append(pkg)
        else:
            info(f"  {pkg} — already installed, skipping")

    if not to_install:
        success("All pacman packages already installed.")
        return

    print()
    info(f"Packages to install ({len(to_install)}):")
    for pkg in to_install:
        print(f"    {pkg}")
    print()

    if not skip_confirm and not confirm("Proceed with pacman install?"):
        warn("Skipping pacman install.")
        return

    flags = ["-S", "--needed", "--noconfirm" if skip_confirm else "--needed"]
    try:
        run(["sudo", "pacman", "-S", "--needed"] + (["--noconfirm"] if skip_confirm else []) + to_install)
        success(f"Installed {len(to_install)} pacman package(s).")
    except Exception as exc:
        die(f"pacman install failed: {exc}")

def aur_install(helper: str, packages: list[str], skip_confirm: bool) -> None:
    """Install AUR packages via the given helper."""
    info("Checking which AUR packages are already installed…")

    to_install = []
    for pkg in packages:
        result = run(["pacman", "-Q", pkg], check=False, capture=True)
        if result.returncode != 0:
            to_install.append(pkg)
        else:
            info(f"  {pkg} — already installed, skipping")

    if not to_install:
        success("All AUR packages already installed.")
        return

    print()
    info(f"AUR packages to install ({len(to_install)}) via {helper}:")
    for pkg in to_install:
        print(f"    {pkg}")
    print()

    if not skip_confirm and not confirm(f"Proceed with {helper} install?"):
        warn("Skipping AUR install.")
        return

    extra_flags = ["--noconfirm"] if skip_confirm else []
    try:
        run([helper, "-S", "--needed"] + extra_flags + to_install)
        success(f"Installed {len(to_install)} AUR package(s).")
    except Exception as exc:
        die(f"AUR install failed: {exc}")

# Entry point

def main() -> None:
    parser = argparse.ArgumentParser(description="Install dotfile packages")
    parser.add_argument("--aur-only",     action="store_true", help="Only install AUR packages")
    parser.add_argument("--pacman-only",  action="store_true", help="Only install pacman packages")
    parser.add_argument("--skip-confirm", action="store_true", help="Auto-confirm all prompts")
    args = parser.parse_args()

    header("Package Installation")

    # Ensure we're on Arch Linux
    if not command_exists("pacman"):
        die("pacman not found. This script only runs on Arch Linux (or derivatives).")

    # Pacman packages
    if not args.aur_only:
        header("Official Repo Packages (pacman)")
        pacman_install(PACMAN_PACKAGES, args.skip_confirm)

    # AUR packages
    if not args.pacman_only:
        header("AUR Packages")
        helper = detect_aur_helper()
        if helper is None:
            warn("No AUR helper found (yay / paru).")
            if args.skip_confirm or confirm("Install yay automatically?"):
                install_yay()
                helper = "yay"
            else:
                warn("Skipping AUR packages — install yay or paru manually, then re-run.")
                return
        else:
            info(f"Using AUR helper: {helper}")

        aur_install(helper, AUR_PACKAGES, args.skip_confirm)

    success("Package installation complete.")

if __name__ == "__main__":
    main()
