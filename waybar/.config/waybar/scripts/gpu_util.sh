#!/usr/bin/env bash
GPU=""

if command -v nvidia-smi >/dev/null 2>&1; then
  GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1)
else
  for p in /sys/class/drm/card*/device/gpu_busy_percent; do
    [ -r "$p" ] && GPU=$(cat "$p") && break
  done
fi

GPU=${GPU//[[:space:]]/}
[ -z "$GPU" ] && GPU="0"

if [ "$GPU" -ge 85 ] 2>/dev/null; then CLASS="critical"
elif [ "$GPU" -ge 60 ] 2>/dev/null; then CLASS="warning"
else CLASS="normal"
fi

echo "{\"text\":\"${GPU}%\",\"class\":\"$CLASS\"}"
