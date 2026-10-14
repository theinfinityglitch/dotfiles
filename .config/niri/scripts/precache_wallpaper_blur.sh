#!/bin/bash
# Pre-generates a blurred copy of every wallpaper for the Niri overview
# backdrop, so set-wallpaper.sh never has to blur on the spot.
# Run this at login (spawn-at-startup) and/or on a timer, or manually
# after adding new wallpapers.
set -euo pipefail

WALLPAPER_DIR="$HOME/dotfiles/backgrounds"
BLUR_DIR="$HOME/.cache/wallpaper-blur"
BLUR_STRENGTH="0x8"   # ImageMagick blur radiusxsigma; raise sigma for more blur

mkdir -p "$BLUR_DIR"
shopt -s nullglob nocaseglob

CONVERT=magick
command -v magick >/dev/null || CONVERT=convert

for IMAGE in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp,gif,bmp,tiff}; do
    [[ -f "$IMAGE" ]] || continue
    NAME=$(basename "$IMAGE")
    BLUR_IMAGE="$BLUR_DIR/${NAME}.png"

    # Skip regeneration if the cached blur is already newer than the source
    if [[ -f "$BLUR_IMAGE" && "$BLUR_IMAGE" -nt "$IMAGE" ]]; then
        continue
    fi

    # For animated images, blur only the first frame. Blurring every frame
    # of a gif is slow and produces a distracting, oversized moving backdrop
    # instead of a still one — this is very likely why gifs "don't work".
    SRC="$IMAGE"
    if [[ "${IMAGE,,}" == *.gif ]]; then
        SRC="${IMAGE}[0]"
    fi

    echo "Blurring: $NAME"
    "$CONVERT" "$SRC" -blur "$BLUR_STRENGTH" "$BLUR_IMAGE"
done

# Prune cached blurs whose source wallpaper was removed
for CACHED in "$BLUR_DIR"/*.png; do
    [[ -f "$CACHED" ]] || continue
    SRC_NAME="${CACHED%.png}"
    SRC_NAME="$(basename "$SRC_NAME")"
    [[ -f "$WALLPAPER_DIR/$SRC_NAME" ]] || rm -f "$CACHED"
done
