#!/bin/bash

[[ -f /tmp/waybar_streamer_mode ]] && echo "" && exit 0

LOGFILE="$HOME/.local/share/clamav-hourly.log"

if [[ ! -f "$LOGFILE" ]]; then
    echo "ClamAV: N/A"
    exit 0
fi

INFECTED=$(grep -i "Infected files" "$LOGFILE" | tail -1 | awk '{print $3}')

if [[ "$INFECTED" =~ ^[0-9]+$ ]]; then
    echo "ClamAV: $INFECTED"
else
    echo "ClamAV: N/A"
fi