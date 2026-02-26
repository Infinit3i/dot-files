#!/usr/bin/env bash
[[ -f /tmp/waybar_streamer_mode ]] && echo "" && exit 0

FLAG="/tmp/waybar_streamer_mode"
if [[ -f "$FLAG" ]]; then
  echo '{"text":"NONE"}'
else
  echo "{\"text\":\"$(date '+%H:%M %a')\"}"
fi