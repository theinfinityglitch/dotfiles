#!/bin/bash
# Directory containing wallpapers
WALLPAPER_DIR="$HOME/dotfiles/backgrounds"

# Select a random wallpaper
IMAGE=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set the wallpaper using awww
awww img "$IMAGE" --transition-type random --transition-duration 2
