#!/usr/bin/env bash
set -euo pipefail

FLAG="/tmp/waybar_streamer_mode"

if [[ -f "$FLAG" ]]; then
    rm -f "$FLAG"
else
    : > "$FLAG"
fi

pkill -RTMIN+8 waybar