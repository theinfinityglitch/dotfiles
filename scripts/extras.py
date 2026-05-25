#!/usr/bin/env python3
"""
extras.py — Clone, build, and install external components:

  1. rnd  (https://github.com/theinfinityglitch/rnd)
         → git clone → cargo build --release → ./target/release/rnd --install

  2. Vicinae extensions (5 repos)
         → git clone each into <dotfiles>/vicinae_extensions/<name>/
         → npm install && npm run build inside each

Usage:
    python3 scripts/extras.py [--rnd-only] [--vicinae-only] [--skip-confirm] [--update]
"""

import argparse
import os
import shutil
import sys
from pathlib import Path

from common import (
    header, info, success, warn, error, die,
    confirm, run, run_shell, command_exists, dotfiles_dir,
    BOLD, RESET, GREEN, YELLOW, CYAN, DIM,
)

# Repo definitions

RND_REPO = "https://github.com/theinfinityglitch/rnd.git"

VICINAE_EXTENSIONS = [
    {
        "name":   "vicinae-bluetooth",
        "repo":   "https://github.com/theinfinityglitch/vicinae-bluetooth.git",
    },
    {
        "name":   "vicinae-network-manager",
        "repo":   "https://github.com/theinfinityglitch/vicinae-network-manager.git",
    },
    {
        "name":   "vicinae-notification-center",
        "repo":   "https://github.com/theinfinityglitch/vicinae-notification-center.git",
    },
    {
        "name":   "vicinae-power-manager",
        "repo":   "https://github.com/theinfinityglitch/vicinae-power-manager.git",
    },
    {
        "name":   "vicinae-wallpaper-selector",
        "repo":   "https://github.com/theinfinityglitch/vicinae-wallpaper-selector.git",
    },
]

# Git helpers

def clone_or_update(repo: str, dest: Path, update: bool) -> bool:
    """
    Clone repo into dest, or pull if dest already exists and --update is set.
    Returns True on success.
    """
    if dest.exists():
        if update:
            info(f"Updating {dest.name}…")
            try:
                run(["git", "-C", str(dest), "pull", "--ff-only"], check=True)
                success(f"Updated: {dest.name}")
                return True
            except Exception as exc:
                warn(f"git pull failed for {dest.name}: {exc} — using existing clone.")
                return True
        else:
            info(f"Directory exists, skipping clone: {dest.name}  (pass --update to refresh)")
            return True

    info(f"Cloning {repo} → {dest}…")
    dest.parent.mkdir(parents=True, exist_ok=True)
    try:
        run(["git", "clone", "--depth=1", repo, str(dest)])
        success(f"Cloned: {dest.name}")
        return True
    except Exception as exc:
        error(f"git clone failed for {repo}: {exc}")
        return False

# rnd

def install_rnd(update: bool, skip_confirm: bool) -> None:
    header("rnd — Rust Notification Daemon")

    # Prerequisites
    missing = [t for t in ("cargo", "git") if not command_exists(t)]
    if missing:
        die(f"Missing required tools: {', '.join(missing)}\n"
            f"  Install them with: sudo pacman -S {' '.join(missing)}")

    # System library check
    for lib in ("gtk4", "gtk4-layer-shell"):
        result = run(["pacman", "-Q", lib], check=False, capture=True)
        if result.returncode != 0:
            warn(f"System library not installed: {lib}")
            warn(f"  Run: sudo pacman -S {lib}")

    clone_dest = Path.home() / ".local" / "src" / "rnd"
    if not clone_or_update(RND_REPO, clone_dest, update):
        return

    # Build
    info("Building rnd (cargo build --release)…")
    info("  This may take a while on first build.")
    try:
        run(["cargo", "build", "--release"], cwd=str(clone_dest))
    except Exception as exc:
        die(f"cargo build failed: {exc}")
    success("Build successful.")

    # Install via the binary's own --install flag
    rnd_bin    = clone_dest / "target" / "release" / "rnd"
    rndctl_bin = clone_dest / "target" / "release" / "rndctl"

    if not rnd_bin.exists():
        die(f"Expected binary not found: {rnd_bin}")

    info("Installing rnd (enables + starts the systemd user service)…")
    if not skip_confirm and not confirm("Run `rnd --install` now?"):
        warn("Skipping rnd install step. Run manually:")
        warn(f"  {rnd_bin} --install")
        return

    try:
        run([str(rnd_bin), "--install"])
        success("rnd installed and service started.")
    except Exception as exc:
        warn(f"rnd --install returned non-zero: {exc}")
        warn("You may need to run it manually once graphical session is active.")

    # Also install rndctl if present
    if rndctl_bin.exists():
        try:
            run([str(rnd_bin), "--install-rndctl", f"--rndctl-path={rndctl_bin}"])
            success("rndctl installed.")
        except Exception as exc:
            warn(f"rndctl install step failed: {exc}")

# Vicinae extensions

def install_vicinae_extensions(update: bool, skip_confirm: bool) -> None:
    header("Vicinae Extensions")

    for tool in ("node", "npm", "git"):
        if not command_exists(tool):
            die(f"'{tool}' not found. Install it with: sudo pacman -S nodejs npm")

    dotfiles   = dotfiles_dir()
    ext_root   = dotfiles / "vicinae_extensions"
    ext_root.mkdir(exist_ok=True)
    info(f"Extensions root: {ext_root}")
    print()

    results: list[tuple[str, str]] = []  # (name, status)

    for ext in VICINAE_EXTENSIONS:
        name = ext["name"]
        repo = ext["repo"]
        dest = ext_root / name

        print(f"  {BOLD}{CYAN}{name}{RESET}")

        # Clone / update
        if not clone_or_update(repo, dest, update):
            results.append((name, "clone failed"))
            print()
            continue

        # npm install
        info(f"  Running npm install in {name}…")
        try:
            run(["npm", "install"], cwd=str(dest))
        except Exception as exc:
            error(f"  npm install failed for {name}: {exc}")
            results.append((name, "npm install failed"))
            print()
            continue

        # npm run build
        info(f"  Running npm run build in {name}…")
        try:
            run(["npm", "run", "build"], cwd=str(dest))
            success(f"  {name} built.")
            results.append((name, "OK"))
        except Exception as exc:
            error(f"  npm run build failed for {name}: {exc}")
            results.append((name, "build failed"))

        print()

    # Summary
    header("Vicinae Extensions Summary")
    for name, status in results:
        if status == "OK":
            print(f"  {GREEN}✓{RESET}  {name}")
        else:
            print(f"  {YELLOW}⚠{RESET}  {name}  {DIM}({status}){RESET}")
    print()

    # Remind user to register extensions with vicinae
    info("To activate extensions, run:")
    info("  vicinae extension install <path>")
    info("or restart vicinae — it picks up extensions from its configured paths.")

# Entry point

def main() -> None:
    parser = argparse.ArgumentParser(description="Install rnd and vicinae extensions")
    parser.add_argument("--rnd-only",     action="store_true", help="Only install rnd")
    parser.add_argument("--vicinae-only", action="store_true", help="Only install vicinae extensions")
    parser.add_argument("--skip-confirm", action="store_true", help="Auto-confirm all prompts")
    parser.add_argument("--update",       action="store_true", help="Pull latest changes in existing repos")
    args = parser.parse_args()

    ran_anything = False

    if not args.vicinae_only:
        if args.skip_confirm or confirm("Build and install rnd (Rust notification daemon)?"):
            install_rnd(update=args.update, skip_confirm=args.skip_confirm)
            ran_anything = True
        else:
            warn("Skipping rnd.")

    if not args.rnd_only:
        if args.skip_confirm or confirm("Clone and build vicinae extensions?"):
            install_vicinae_extensions(update=args.update, skip_confirm=args.skip_confirm)
            ran_anything = True
        else:
            warn("Skipping vicinae extensions.")

    if ran_anything:
        success("Extras installation complete.")
    else:
        info("Nothing was installed.")

if __name__ == "__main__":
    main()