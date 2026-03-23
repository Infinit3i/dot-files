#!/bin/bash

MODE=$(makoctl mode 2>/dev/null)

if echo "$MODE" | grep -q "do-not-disturb"; then
  # DND OFF — restore notifications and unmute notification streams
  makoctl mode -r do-not-disturb
  # Unmute all corked notification/communication sink inputs
  for idx in $(pactl list sink-inputs short 2>/dev/null | awk '{print $1}'); do
    role=$(pactl list sink-inputs 2>/dev/null | grep -A 50 "Sink Input #${idx}" | grep "media.role" | head -1 | sed 's/.*= "\(.*\)"/\1/')
    if [[ "$role" == "notification" || "$role" == "event" ]]; then
      pactl set-sink-input-mute "$idx" 0
    fi
  done
else
  # DND ON — suppress notifications and mute notification streams
  makoctl mode -a do-not-disturb
  # Mute all notification/event sink inputs
  for idx in $(pactl list sink-inputs short 2>/dev/null | awk '{print $1}'); do
    role=$(pactl list sink-inputs 2>/dev/null | grep -A 50 "Sink Input #${idx}" | grep "media.role" | head -1 | sed 's/.*= "\(.*\)"/\1/')
    if [[ "$role" == "notification" || "$role" == "event" ]]; then
      pactl set-sink-input-mute "$idx" 1
    fi
  done
fi
