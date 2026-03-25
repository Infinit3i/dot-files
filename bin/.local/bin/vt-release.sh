#!/bin/bash
#
# vt-release.sh — Manually release a file from quarantine
# Usage: vt-release.sh <filename>
#        vt-release.sh --list
#

QUARANTINE_DIR="$HOME/Downloads/.quarantine"
DEST_DIR="$HOME/Downloads"
LOG_FILE="$HOME/.local/share/vt-watcher.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [[ "$1" == "--list" || -z "$1" ]]; then
    echo "Quarantined files:"
    echo "---"
    if [[ -d "$QUARANTINE_DIR" ]]; then
        ls -lah "$QUARANTINE_DIR" 2>/dev/null | tail -n +2
        count=$(find "$QUARANTINE_DIR" -maxdepth 1 -type f | wc -l)
        echo "---"
        echo "Total: $count file(s)"
    else
        echo "(none)"
    fi
    exit 0
fi

filename="$1"
quarantine_path="$QUARANTINE_DIR/$filename"

if [[ ! -f "$quarantine_path" ]]; then
    echo "ERROR: File not found in quarantine: $filename"
    echo "Use --list to see quarantined files"
    exit 1
fi

read -rp "Release '$filename' from quarantine? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    mv "$quarantine_path" "$DEST_DIR/$filename"
    log "RELEASED: $filename (manual override)"
    echo "Released: $DEST_DIR/$filename"
else
    echo "Cancelled."
fi
