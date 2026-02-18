#!/usr/bin/env bash
set -euo pipefail

# List sinks from wpctl status output; select via wofi; set default sink.
choice="$(
  wpctl status |
    awk '
      $1 ~ /^[0-9]+\./ {id=$1; sub(/\./,"",id); line=$0}
      /Sinks:/ {insinks=1; next}
      insinks && $1 ~ /^[0-9]+\./ {print id "  " substr(line, index(line,$2))}
      insinks && /^ *Sources:/ {exit}
    ' |
    wofi --dmenu --prompt "Audio output"
)"

[ -z "${choice}" ] && exit 0
sink_id="$(echo "$choice" | awk "{print \$1}")"
wpctl set-default "$sink_id"

