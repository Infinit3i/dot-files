#!/usr/bin/env bash
set -euo pipefail

FLAG="/tmp/waybar_streamer_mode"

if [[ -f "$FLAG" ]]; then
    rm -f "$FLAG"
    # Disable DND when leaving streamer mode
    if makoctl mode 2>/dev/null | grep -q "do-not-disturb"; then
        ~/.config/waybar/scripts/dnd_toggle.sh
    fi
else
    : > "$FLAG"
    # Enable DND when entering streamer mode
    if ! makoctl mode 2>/dev/null | grep -q "do-not-disturb"; then
        ~/.config/waybar/scripts/dnd_toggle.sh
    fi
fi

# Restart waybar in a fully detached session so killing waybar won't kill this process
setsid bash -c 'killall waybar 2>/dev/null || true; sleep 0.5; exec waybar' &>/dev/null &