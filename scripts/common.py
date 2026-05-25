"""
common.py — Shared helpers: colors, logging, subprocess wrappers.
"""

import subprocess
import sys
import os
from pathlib import Path

# ANSI colors

RESET  = "\033[0m"
BOLD   = "\033[1m"

RED    = "\033[0;31m"
GREEN  = "\033[0;32m"
YELLOW = "\033[0;33m"
BLUE   = "\033[0;34m"
CYAN   = "\033[0;36m"
WHITE  = "\033[0;37m"
DIM    = "\033[2m"

# Print helpers

def header(text: str) -> None:
    width = 60
    print()
    print(f"{BOLD}{CYAN}{'─' * width}{RESET}")
    print(f"{BOLD}{CYAN}  {text}{RESET}")
    print(f"{BOLD}{CYAN}{'─' * width}{RESET}")

def info(text: str) -> None:
    print(f"{BLUE}  →{RESET} {text}")

def success(text: str) -> None:
    print(f"{GREEN}  ✓{RESET} {text}")

def warn(text: str) -> None:
    print(f"{YELLOW}  ⚠{RESET}  {text}")

def error(text: str) -> None:
    print(f"{RED}  ✗{RESET} {text}", file=sys.stderr)

def die(text: str, code: int = 1) -> None:
    error(text)
    sys.exit(code)

def ask(prompt: str, default: str = "") -> str:
    """Prompt user for input, returning stripped response."""
    try:
        suffix = f" [{default}]" if default else ""
        response = input(f"{BOLD}{YELLOW}  ?{RESET} {prompt}{suffix}: ").strip()
        return response if response else default
    except (EOFError, KeyboardInterrupt):
        print()
        die("Aborted by user.")
        return ""

def confirm(prompt: str, default: bool = True) -> bool:
    """Ask a yes/no question, returns bool."""
    hint = "Y/n" if default else "y/N"
    try:
        response = input(f"{BOLD}{YELLOW}  ?{RESET} {prompt} [{hint}]: ").strip().lower()
    except (EOFError, KeyboardInterrupt):
        print()
        die("Aborted by user.")
        return False
    if response in ("y", "yes"):
        return True
    if response in ("n", "no"):
        return False
    return default

# Shell helpers

def run(cmd: list[str], check: bool = True, capture: bool = False, cwd: str | None = None) -> subprocess.CompletedProcess:
    """Run a command, optionally capturing output."""
    kwargs: dict = {"cwd": cwd}
    if capture:
        kwargs["stdout"] = subprocess.PIPE
        kwargs["stderr"] = subprocess.PIPE
        kwargs["text"]   = True
    result = subprocess.run(cmd, **kwargs)
    if check and result.returncode != 0:
        raise subprocess.CalledProcessError(result.returncode, cmd)
    return result

def run_shell(cmd: str, check: bool = True, cwd: str | None = None) -> int:
    """Run a raw shell string (uses shell=True)."""
    result = subprocess.run(cmd, shell=True, cwd=cwd)
    if check and result.returncode != 0:
        raise subprocess.CalledProcessError(result.returncode, cmd)
    return result.returncode

def command_exists(name: str) -> bool:
    """Return True if `name` is on PATH."""
    return subprocess.run(
        ["which", name], capture_output=True
    ).returncode == 0

def dotfiles_dir() -> Path:
    """Resolve the dotfiles root: parent of the scripts/ folder."""
    return Path(__file__).resolve().parent.parent