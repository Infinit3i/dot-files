#!/bin/bash

LOG_DIR="/var/log/afw"
HOUR=$(date +%H)
MIN=$(date +%M)
SLOT_MIN=$(( (10#$MIN / 30) * 30 ))
SLOT_FILE=$(printf "blocked-%s-%02d.log" "$HOUR" "$SLOT_MIN")

COUNT=0
if [[ -f "$LOG_DIR/$SLOT_FILE" ]]; then
  COUNT=$(grep -c "BLOCKED" "$LOG_DIR/$SLOT_FILE" 2>/dev/null || echo 0)
fi

if [ "$COUNT" -eq 0 ]; then
  CLASS="normal"
elif [ "$COUNT" -le 20 ]; then
  CLASS="warning"
else
  CLASS="critical"
fi

echo "{\"text\":\"AFW $COUNT\",\"tooltip\":\"AFW blocks (current slot): $COUNT\",\"class\":\"$CLASS\"}"
