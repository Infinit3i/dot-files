#!/bin/bash
CAL="$(cal)"
# Try readable history; fallback if it’s JSON and jq exists
if command -v jq >/dev/null 2>&1; then
  HIST="$(makoctl history 2>/dev/null | jq -r '.. | objects | .summary? // empty' | tail -n 20)"
else
  HIST="$(makoctl history 2>/dev/null | tail -n 50)"
fi

{
  echo "=== Calendar (this month) ==="
  echo "$CAL"
  echo "=== Mako (recent) ==="
  [ -n "$HIST" ] && echo "$HIST" || echo "(no history)"
} | wofi --dmenu --prompt "Clock" --width 500 --lines 25 --cache-file /dev/null
