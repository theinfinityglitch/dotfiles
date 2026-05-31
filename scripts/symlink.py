#!/usr/bin/env python3
"""
Usage:
    python3 scripts/symlink.py [--skip-backup] [--force]
    python3 scripts/symlink.py --list-backups
    python3 scripts/symlink.py --restore <backup-name>
"""

import argparse
import os
import shutil
import sys
from datetime import datetime
from pathlib import Path

from common import (
    header, info, success, warn, error, die,
    ask, confirm, dotfiles_dir,
    BOLD, RESET, CYAN, GREEN, YELLOW, RED, DIM,
)

def symlink_map(dotfiles: Path, home: Path) -> list[tuple[Path, Path]]:
    config = home / ".config"
    return [
        # ~/.config entries
        (dotfiles / ".config" / "hypr",       config / "hypr"),
        (dotfiles / ".config" / "waybar",     config / "waybar"),
        (dotfiles / ".config" / "rnd",        config / "rnd"),
        (dotfiles / ".config" / "kitty",      config / "kitty"),
        (dotfiles / ".config" / "fastfetch",  config / "fastfetch"),
        (dotfiles / ".config" / "vicinae",    config / "vicinae"),
        (dotfiles / ".config" / "wlogout",    config / "wlogout"),
        (dotfiles / ".config" / "gtk-3.0",    config / "gtk-3.0"),
        (dotfiles / ".config" / "gtk-4.0",    config / "gtk-4.0"),
        (dotfiles / ".config" / "kdeglobals", config / "kdeglobals"),
        (dotfiles / ".config" / "qt5ct",      config / "qt5ct"),
        (dotfiles / ".config" / "qt6ct",      config / "qt6ct"),
        (dotfiles / ".config" / "nvim",       config / "nvim")
    ]

# Backup helpers

BACKUP_ROOT = Path.home() / ".dotfiles_backups"

def backup_dir(name: str) -> Path:
    return BACKUP_ROOT / name

def list_backups() -> list[Path]:
    if not BACKUP_ROOT.exists():
        return []
    return sorted(BACKUP_ROOT.iterdir(), key=lambda p: p.stat().st_mtime, reverse=True)

def print_backups() -> None:
    backups = list_backups()
    if not backups:
        info("No backups found in ~/.dotfiles_backups/")
        return
    print(f"\n{BOLD}{CYAN}  Available backups:{RESET}")
    for b in backups:
        mtime = datetime.fromtimestamp(b.stat().st_mtime).strftime("%Y-%m-%d %H:%M:%S")
        print(f"    {GREEN}{b.name:<30}{RESET} {DIM}{mtime}{RESET}")
    print()

def do_backup(targets: list[tuple[Path, Path]], backup_name: str) -> None:
    """Copy each existing target into the backup directory."""
    dest_root = backup_dir(backup_name)
    if dest_root.exists():
        warn(f"Backup '{backup_name}' already exists — overwriting.")
        shutil.rmtree(dest_root)
    dest_root.mkdir(parents=True)

    backed_up = 0
    for _, target in targets:
        if not target.exists() and not target.is_symlink():
            continue  # nothing to back up
        # Preserve relative structure under home
        try:
            rel = target.relative_to(Path.home())
        except ValueError:
            rel = Path(target.name)
        dest = dest_root / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        if target.is_symlink():
            # Copy the link itself (not the target)
            link_target = os.readlink(target)
            if dest.exists() or dest.is_symlink():
                dest.unlink()
            os.symlink(link_target, dest)
        elif target.is_dir():
            shutil.copytree(target, dest, symlinks=True)
        else:
            shutil.copy2(target, dest)
        backed_up += 1

    success(f"Backup '{backup_name}' created ({backed_up} items) → {dest_root}")

def restore_backup(backup_name: str, home: Path) -> None:
    """Restore a backup by copying its contents back to home."""
    src_root = backup_dir(backup_name)
    if not src_root.exists():
        die(f"Backup '{backup_name}' not found in {BACKUP_ROOT}")

    header(f"Restoring backup: {backup_name}")
    for item in src_root.rglob("*"):
        if item.is_dir() and not item.is_symlink():
            continue
        try:
            rel = item.relative_to(src_root)
        except ValueError:
            continue
        dest = home / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        if dest.exists() or dest.is_symlink():
            if dest.is_dir() and not dest.is_symlink():
                shutil.rmtree(dest)
            else:
                dest.unlink()
        if item.is_symlink():
            os.symlink(os.readlink(item), dest)
        elif item.is_dir():
            shutil.copytree(item, dest, symlinks=True)
        else:
            shutil.copy2(item, dest)
        info(f"Restored: {dest}")

    success(f"Backup '{backup_name}' restored.")

# Config identity check

def _is_same_config(targets: list[tuple[Path, Path]], dotfiles: Path) -> bool:
    """
    Return True only when EVERY target already points to the right source.
    A single missing or mismatched symlink returns False.
    """
    for src, target in targets:
        if not target.is_symlink():
            return False
        try:
            if Path(os.readlink(target)).resolve() != src.resolve():
                return False
        except Exception:
            return False
    return True

def _describe_conflicts(targets: list[tuple[Path, Path]], dotfiles: Path) -> list[str]:
    """Return human-readable descriptions of what would be overwritten."""
    lines = []
    for src, target in targets:
        if not target.exists() and not target.is_symlink():
            continue
        if target.is_symlink():
            resolved = Path(os.readlink(target)).resolve()
            if resolved == src.resolve():
                continue  # already correct
            lines.append(f"symlink → {resolved}  (expected → {src})")
        elif target.is_dir():
            lines.append(f"directory  {target}")
        else:
            lines.append(f"file       {target}")
    return lines

# Symlinking

def create_symlinks(targets: list[tuple[Path, Path]], force: bool) -> None:
    created = skipped = errors = 0
    for src, target in targets:
        if not src.exists():
            warn(f"Source does not exist, skipping: {src}")
            errors += 1
            continue

        target.parent.mkdir(parents=True, exist_ok=True)

        # Remove existing file/dir/symlink if force or it's a wrong symlink
        if target.exists() or target.is_symlink():
            if target.is_symlink() and Path(os.readlink(target)).resolve() == src.resolve():
                info(f"Already linked: {target}")
                skipped += 1
                continue
            if force:
                if target.is_dir() and not target.is_symlink():
                    shutil.rmtree(target)
                else:
                    target.unlink()
            else:
                warn(f"Target exists (use --force to overwrite): {target}")
                errors += 1
                continue

        target.symlink_to(src)
        success(f"Linked: {target}  →  {src}")
        created += 1

    print()
    summary = (
        f"  {GREEN}{created} created{RESET}  "
        f"{DIM if skipped == 0 else ''}{skipped} already OK{RESET}  "
        f"{RED if errors > 0 else DIM}{errors} skipped/errors{RESET}"
    )
    print(f"  Symlinks: {summary}")

# Entry point

def main() -> None:
    parser = argparse.ArgumentParser(description="Symlink dotfiles with backup support")
    parser.add_argument("--skip-backup",   action="store_true", help="Never create a backup")
    parser.add_argument("--force",         action="store_true", help="Overwrite existing non-symlink targets")
    parser.add_argument("--list-backups",  action="store_true", help="List available backups and exit")
    parser.add_argument("--restore",       metavar="NAME",      help="Restore a named backup")
    args = parser.parse_args()

    home     = Path.home()
    dotfiles = dotfiles_dir()

    # List / restore modes
    if args.list_backups:
        header("Available Backups")
        print_backups()
        return

    if args.restore:
        restore_backup(args.restore, home)
        return

    header("Symlinking Dotfiles")
    info(f"Dotfiles root: {dotfiles}")
    info(f"Home:          {home}")

    targets = symlink_map(dotfiles, home)

    # Backup decision
    if not args.skip_backup:
        if _is_same_config(targets, dotfiles):
            success("All symlinks already point to this dotfiles folder — no backup needed.")
        else:
            conflicts = _describe_conflicts(targets, dotfiles)
            if conflicts:
                print()
                warn("The following existing configs would be replaced:")
                for c in conflicts:
                    print(f"    {YELLOW}{c}{RESET}")
                print()

                if confirm("Create a backup before proceeding?", default=True):
                    default_name = datetime.now().strftime("backup_%Y%m%d_%H%M%S")
                    name = ask("Backup name", default=default_name)
                    if not name:
                        name = default_name
                    # Reject names with slashes or dots that could cause path traversal
                    safe_name = name.replace("/", "_").replace("..", "_")
                    do_backup(targets, safe_name)
                    print()
                else:
                    warn("Proceeding without backup.")
                    print()

    # Symlink
    create_symlinks(targets, force=args.force or True)  # force=True: backup was already offered

if __name__ == "__main__":
    main()
