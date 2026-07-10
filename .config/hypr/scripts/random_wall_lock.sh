#!/usr/bin/env bash
# Directory containing wallpapers
WALLPAPER_DIR="$HOME/dotfiles/backgrounds"
CURRENT_WALLPAPER_PATH="$HOME/.current_lock_wallpaper"

# Select a random wallpaper
IMAGE=$(find "$WALLPAPER_DIR" -type f -iname "*.png" | shuf -n 1)

cp $IMAGE $CURRENT_WALLPAPER_PATH
