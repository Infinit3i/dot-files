#!/bin/bash

LOG_DIR="/var/log/afw"
clear
echo "AFW - Blocked Connections"
echo "----------------------------------------"

if [[ ! -d "$LOG_DIR" ]]; then
  echo "No AFW log directory found."
  read -r
  exit 0
fi

# Show all blocked logs from today (most recent first)
FOUND=0
for f in $(ls -t "$LOG_DIR"/blocked-*.log 2>/dev/null); do
  # Only show files modified today
  if [[ $(date -r "$f" +%Y-%m-%d) == $(date +%Y-%m-%d) ]]; then
    FOUND=1
    cat "$f"
  fi
done

if [[ "$FOUND" -eq 0 ]]; then
  echo "No blocked connections today."
fi

echo ""
read -r -p "Press Enter to close"
