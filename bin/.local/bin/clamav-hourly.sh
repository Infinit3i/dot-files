#!/bin/bash

LOGFILE="$HOME/.local/share/clamav-hourly.log"
SCAN_DIR="$HOME"

# clamdscan does not honor --exclude-dir, so we build the file list via
# `find` with -prune and feed it through --file-list.
find "$SCAN_DIR" \
  \( \
       -path "$HOME/.cache" \
    -o -path "$HOME/.local/share/docker" \
    -o -path "$HOME/.local/share/containers" \
    -o -path "$HOME/.local/share/Trash" \
    -o -path "$HOME/.zoom" \
    -o -path "$HOME/.config/zoom" \
    -o -path "$HOME/.steam" \
    -o -path "$HOME/.config/obsidian/IndexedDB" \
  \) -prune -o -type f -print 2>/dev/null \
  | clamdscan \
      --multiscan \
      --fdpass \
      --infected \
      --file-list=- >> "$LOGFILE" 2>&1

# clamdscan exits 1 for infections found, 2 for errors
# Only fail on actual errors, not on "infected found"
exit_code=$?
if [ "$exit_code" -eq 2 ]; then
  exit 2
fi
exit 0
