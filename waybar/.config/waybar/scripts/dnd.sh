#!/bin/bash

MODE=$(makoctl mode 2>/dev/null)

if echo "$MODE" | grep -q "do-not-disturb"; then
  echo '{"text":"󰂛","tooltip":"Do Not Disturb: ON","class":"on"}'
else
  echo '{"text":"󰂚","tooltip":"Do Not Disturb: OFF","class":"off"}'
fi
