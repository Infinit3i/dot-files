#!/bin/bash

LOGFILE="$HOME/.local/share/clamav-hourly.log"
SCAN_DIR="$HOME"

clamdscan \
  --multiscan \
  --fdpass \
  --infected \
  "$SCAN_DIR" >> "$LOGFILE"
