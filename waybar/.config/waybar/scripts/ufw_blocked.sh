#!/bin/bash
[[ -f /tmp/waybar_streamer_mode ]] && echo "" && exit 0

COUNT=$(journalctl -q -o cat --since "30 minutes ago" -g "UFW BLOCK" --no-pager 2>/dev/null | wc -l)

if [ "$COUNT" -eq 0 ]; then
  CLASS="normal"
elif [ "$COUNT" -le 3 ]; then
  CLASS="warning"
else
  CLASS="critical"
fi

echo "{\"text\":\"UFW $COUNT\",\"tooltip\":\"UFW blocks (last 30 min): $COUNT\",\"class\":\"$CLASS\"}"
