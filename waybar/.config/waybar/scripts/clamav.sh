#!/bin/bash

LOGFILE="$HOME/.local/share/clamav-hourly.log"

# Check if log exists
if [[ ! -f "$LOGFILE" ]]; then
    echo "ClamAV: N/A"
    exit 0
fi

# Get last scan in the last hour
LAST_SCAN=$(tail -n 20 "$LOGFILE" | grep -i "Infected files" | tail -n1)

if [[ -z "$LAST_SCAN" ]]; then
    echo "ClamAV: ✅"
else
    # Extract number of infected files
    INFECTED=$(echo "$LAST_SCAN" | awk '{print $3}')
    if [[ "$INFECTED" -eq 0 ]]; then
        echo "ClamAV: ✅"
    else
        echo "ClamAV: ❌ $INFECTED"
    fi
fi
