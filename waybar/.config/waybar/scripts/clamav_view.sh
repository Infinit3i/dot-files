#!/bin/bash

LOGFILE="$HOME/.local/share/clamav-hourly.log"
clear
echo "ClamAV Scan Results"
echo "--------------------------------"
if [[ ! -f "$LOGFILE" ]]; then
    echo "No scan log found at $LOGFILE"
else
    cat "$LOGFILE"
fi
echo ""
echo "--------------------------------"
read -r -p "Press Enter to close"
