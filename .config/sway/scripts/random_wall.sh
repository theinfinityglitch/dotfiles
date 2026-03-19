#!/bin/bash
# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Assets/backgrounds"

# Select a random wallpaper
IMAGE=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set the wallpaper using swww
swww img "$IMAGE" --transition-type random --transition-duration 2
