#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/wallpaper"

change_wallpaper() {
    local wallpapers=()

    while IFS= read -r -d $'\0' file; do
        wallpapers+=("$file")
    done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0)

    if [ ${#wallpapers[@]} -eq 0 ]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        return 1
    fi

    local random_index=$((RANDOM % ${#wallpapers[@]}))
    local selected_wallpaper="${wallpapers[$random_index]}"

    echo "Selected wallpaper: $selected_wallpaper"

    # Make sure hyprpaper is running
    if ! pgrep -x hyprpaper >/dev/null; then
        echo "hyprpaper is not running!"
        return 1
    fi

    # Apply via IPC (no restart, no config rewrite)
    hyprctl hyprpaper preload "$selected_wallpaper"
    hyprctl hyprpaper wallpaper ",$selected_wallpaper"
}

# Validate directory
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory does not exist: $WALLPAPER_DIR"
    exit 1
fi

if [ "$1" = "once" ]; then
    change_wallpaper
else
    echo "Starting wallpaper rotation..."
    while true; do
        change_wallpaper
        sleep 60 #60 seconds
    done
fi