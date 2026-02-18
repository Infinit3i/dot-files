#!/usr/bin/env bash
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1
  exit 0
fi
for p in /sys/class/drm/card*/device/gpu_busy_percent; do
  [ -r "$p" ] && cat "$p" && exit 0
done
echo "N/A"
