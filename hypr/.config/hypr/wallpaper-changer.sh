#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="${HOME}/wallpapers"
MONITORS=("DP-3" "DP-4" "HDMI-A-5")

mapfile -t IMAGES < <(find "$WALLPAPER_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \))
(( ${#IMAGES[@]} > 0 )) || { echo "No images found in $WALLPAPER_DIR" >&2; exit 1; }

pick_unique() {
  local -n _out=$1
  _out=()
  local need=${#MONITORS[@]}
  (( ${#IMAGES[@]} >= need )) || need=${#IMAGES[@]}
  mapfile -t _out < <(printf '%s\n' "${IMAGES[@]}" | shuf -n "$need")
}

while true; do
  pick_unique PICKS

  for i in "${!MONITORS[@]}"; do
    mon="${MONITORS[$i]}"
    img="${PICKS[$(( i % ${#PICKS[@]} ))]}"
    hyprctl hyprpaper reload "${mon},${img}"
  done

  sleep 180
done