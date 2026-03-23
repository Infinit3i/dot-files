#!/usr/bin/env bash
set -euo pipefail

FLAG="/tmp/waybar_streamer_mode"

if [[ -f "$FLAG" ]]; then
    rm -f "$FLAG"
else
    : > "$FLAG"
fi

# Restart waybar so all modules re-evaluate exec-if immediately
killall waybar 2>/dev/null
nohup waybar &>/dev/null &