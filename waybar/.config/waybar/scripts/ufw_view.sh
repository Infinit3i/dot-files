#!/bin/bash
OUT=$(journalctl -q -o cat --since "30 minutes ago" -g "UFW BLOCK" --no-pager 2>/dev/null)
clear
echo "UFW Blocks (Last 30 Minutes)"
echo "--------------------------------"
if [ -z "$OUT" ]; then
  echo "No UFW BLOCK entries in the last 30 minutes."
else
  echo "$OUT"
fi
read -r
