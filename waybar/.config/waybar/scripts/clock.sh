#!/usr/bin/env bash

FLAG="/tmp/waybar_streamer_mode"
if [[ -f "$FLAG" ]]; then
  echo '{"text":"NONE"}'
else
  DAY=$(date '+%-d')
  # Highlight current day with pango markup
  CAL=$(cal | sed 's/\x1b\[[0-9;]*m//g' | sed "s/\b${DAY}\b/<b><u>${DAY}<\/u><\/b>/")
  TOOLTIP=$(echo "$CAL" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')
  echo "{\"text\":\"$(date '+%H:%M %a')\",\"tooltip\":\"$TOOLTIP\"}"
fi