#!/bin/bash

# Get AFW stats: active apps / open ports / blocked apps
APPS=0
PORTS=0
BLOCKS=0
TOOLTIP="AFW not running"
CLASS="critical"

STATUS=$(sudo afw status 2>/dev/null) || true
if [ -n "$STATUS" ]; then
  APPS=$(echo "$STATUS" | grep -oP 'Active apps:\s+\K[0-9]+')
  PORTS=$(echo "$STATUS" | grep -c '→')
  PENDING=$(sudo afw pending 2>/dev/null) || true
  BLOCKS=$(echo "$PENDING" | grep -cE '^\s+\S+.*\(') || true
  # Ensure integers
  APPS=${APPS:-0}
  PORTS=${PORTS:-0}
  BLOCKS=${BLOCKS:-0}

  APP_LIST=$(echo "$STATUS" | grep -oP '^\s+\K\S+(?= -)' | paste -sd, -)
  TOOLTIP="Apps / Ports / Blocked\\nActive: $APPS apps, $PORTS ports open, $BLOCKS blocked\\n$APP_LIST"

  if [ "$BLOCKS" -eq 0 ] 2>/dev/null; then
    CLASS="normal"
  elif [ "$BLOCKS" -le 5 ] 2>/dev/null; then
    CLASS="warning"
  else
    CLASS="critical"
  fi
fi

echo "{\"text\":\"AFW $APPS / $PORTS / $BLOCKS\",\"tooltip\":\"$TOOLTIP\",\"class\":\"$CLASS\"}"
