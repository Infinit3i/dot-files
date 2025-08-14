#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/wallpapers"

# Pick a random image from the directory
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | shuf -n 1)

# Apply to all unbound monitors
hyprctl hyprpaper reload ,"$WALLPAPER"

