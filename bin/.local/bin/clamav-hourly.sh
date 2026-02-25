#!/bin/bash

LOGFILE="$HOME/.local/share/clamav-hourly.log"
SCAN_DIR="$HOME"

clamdscan \
  --multiscan \
  --fdpass \
  --infected \
  --exclude-dir="\.git$" \
  --exclude-dir="node_modules$" \
  --exclude-dir="target$" \
  --exclude-dir="dist$" \
  --exclude-dir="build$" \
  "$SCAN_DIR" >> "$LOGFILE"
