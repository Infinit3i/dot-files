#!/bin/bash

COUNT=$(journalctl -q -o cat --since "30 minutes ago" -g "UFW BLOCK" --no-pager 2>/dev/null | wc -l)

if [ "$COUNT" -eq 0 ]; then
  CLASS="green"
elif [ "$COUNT" -le 3 ]; then
  CLASS="orange"
else
  CLASS="red"
fi

echo "{\"text\":\"UFW $COUNT\",\"tooltip\":\"UFW blocks (last 30 min): $COUNT\",\"class\":\"$CLASS\"}"
