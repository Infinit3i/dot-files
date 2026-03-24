#!/usr/bin/env bash
set -euo pipefail

FLAG="/tmp/waybar_streamer_mode"
NOTIFIED="/tmp/obs_streamer_notified"

cleanup() { rm -f "$NOTIFIED"; }
trap cleanup EXIT

ask() {
    local prompt="$1"
    echo -e "Yes\nNo" | rofi -dmenu -p "$prompt" -theme-str 'window {width: 300px;}' 2>/dev/null
}

while true; do
    if pgrep -x obs >/dev/null 2>&1; then
        if [[ ! -f "$FLAG" && ! -f "$NOTIFIED" ]]; then
            : > "$NOTIFIED"
            choice=$(ask "OBS detected — enable streamer mode?")
            if [[ "$choice" == "Yes" && ! -f "$FLAG" ]]; then
                ~/.config/waybar/scripts/streamer_mode.sh
            fi
        fi
    else
        rm -f "$NOTIFIED"
        if [[ -f "$FLAG" ]]; then
            choice=$(ask "OBS closed — disable streamer mode?")
            if [[ "$choice" == "Yes" && -f "$FLAG" ]]; then
                ~/.config/waybar/scripts/streamer_mode.sh
            fi
        fi
    fi
    sleep 5
done
