#!/bin/bash
# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Assets/backgrounds"
CURRENT_WALLPAPER_PATH="$HOME/.config/hypr/.current_wallpaper"

# Select a random wallpaper
IMAGE=$(find "$WALLPAPER_DIR" -type f -iname "*.png" | shuf -n 1)

# Set the wallpaper using swww
cp $IMAGE $CURRENT_WALLPAPER_PATH
