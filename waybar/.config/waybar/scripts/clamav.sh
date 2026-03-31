#!/bin/bash

LOGFILE="$HOME/.local/share/clamav-hourly.log"

if [[ ! -f "$LOGFILE" ]]; then
    printf '{"text":"N/A","tooltip":"ClamAV","class":"normal"}\n'
    exit 0
fi

INFECTED=$(grep -i "Infected files" "$LOGFILE" | tail -1 | awk '{print $3}')

if [[ ! "$INFECTED" =~ ^[0-9]+$ ]]; then
    printf '{"text":"N/A","tooltip":"ClamAV","class":"normal"}\n'
elif [[ "$INFECTED" -gt 0 ]]; then
    printf '{"text":"ClamAV: %s","tooltip":"ClamAV","class":"critical"}\n' "$INFECTED"
else
    printf '{"text":"0","tooltip":"ClamAV","class":"normal"}\n'
fi
