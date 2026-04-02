#!/bin/bash

LOGFILE="$HOME/.local/share/clamav-hourly.log"
SCAN_DIR="$HOME"

clamdscan \
  --multiscan \
  --fdpass \
  --infected \
  --exclude-dir='^/home/infinit3i/\.cache' \
  --exclude-dir='^/home/infinit3i/\.local/share/docker' \
  --exclude-dir='^/home/infinit3i/\.local/share/containers' \
  --exclude-dir='^/home/infinit3i/\.local/share/Trash' \
  "$SCAN_DIR" >> "$LOGFILE" 2>&1

# clamdscan exits 1 for infections found, 2 for errors
# Only fail on actual errors, not on "infected found"
exit_code=$?
if [ "$exit_code" -eq 2 ]; then
  exit 2
fi
exit 0
