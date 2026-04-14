#!/usr/bin/env bash
GPU=""
TOOLTIP=""

if command -v nvidia-smi >/dev/null 2>&1; then
  LINE=$(nvidia-smi \
    --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw \
    --format=csv,noheader,nounits 2>/dev/null | head -n1)
  IFS=',' read -r NAME GPU TEMP MEM_USED MEM_TOTAL POWER <<< "$LINE"
  NAME="${NAME#"${NAME%%[![:space:]]*}"}"; NAME="${NAME%"${NAME##*[![:space:]]}"}"
  GPU="${GPU//[[:space:]]/}"
  TEMP="${TEMP//[[:space:]]/}"
  MEM_USED="${MEM_USED//[[:space:]]/}"
  MEM_TOTAL="${MEM_TOTAL//[[:space:]]/}"
  POWER="${POWER//[[:space:]]/}"
  TOOLTIP="${NAME}\nUtil: ${GPU}%\nTemp: ${TEMP}°C\nVRAM: ${MEM_USED} / ${MEM_TOTAL} MiB\nPower: ${POWER} W"
else
  for p in /sys/class/drm/card*/device/gpu_busy_percent; do
    [ -r "$p" ] || continue
    GPU=$(cat "$p")
    DEV_DIR=$(dirname "$p")
    CARD=$(basename "$(dirname "$DEV_DIR")")
    NAME=$(cat "$DEV_DIR/../uevent" 2>/dev/null | grep -m1 DRIVER= | cut -d= -f2)
    TEMP_RAW=$(cat "$DEV_DIR"/hwmon/hwmon*/temp1_input 2>/dev/null | head -n1)
    [ -n "$TEMP_RAW" ] && TEMP=$((TEMP_RAW/1000))
    MEM_USED=$(cat "$DEV_DIR/mem_info_vram_used" 2>/dev/null)
    MEM_TOTAL=$(cat "$DEV_DIR/mem_info_vram_total" 2>/dev/null)
    if [ -n "$MEM_USED" ] && [ -n "$MEM_TOTAL" ]; then
      MEM_USED_MIB=$((MEM_USED/1024/1024))
      MEM_TOTAL_MIB=$((MEM_TOTAL/1024/1024))
      VRAM="${MEM_USED_MIB} / ${MEM_TOTAL_MIB} MiB"
    fi
    TOOLTIP="${CARD} (${NAME})\nUtil: ${GPU}%"
    [ -n "$TEMP" ] && TOOLTIP="${TOOLTIP}\nTemp: ${TEMP}°C"
    [ -n "$VRAM" ] && TOOLTIP="${TOOLTIP}\nVRAM: ${VRAM}"
    break
  done
fi

GPU=${GPU//[[:space:]]/}
[ -z "$GPU" ] && GPU="0"
[ -z "$TOOLTIP" ] && TOOLTIP="GPU: ${GPU}%"

if [ "$GPU" -ge 85 ] 2>/dev/null; then CLASS="critical"
elif [ "$GPU" -ge 55 ] 2>/dev/null; then CLASS="warning"
else CLASS="normal"
fi

echo "{\"text\":\"${GPU}%\",\"tooltip\":\"${TOOLTIP}\",\"class\":\"$CLASS\"}"
