#!/usr/bin/env bash

# Get external IP
EXT_IP=$(curl -fsS --max-time 2 https://api.ipify.org 2>/dev/null)

# Detect interface and connection type
WIFI_IF=$(ip -o link show up | awk -F': ' '{print $2}' | grep -E '^wl' | head -1)
ETH_IF=$(ip -o link show up | awk -F': ' '{print $2}' | grep -E '^(en|eth)' | head -1)

if [[ -n "$WIFI_IF" ]]; then
    SSID=$(iwgetid -r 2>/dev/null || echo "")
    SIGNAL=$(awk 'NR==3 {printf "%.0f", $3*100/70}' /proc/net/wireless 2>/dev/null)
    LOCAL_IP=$(ip -4 addr show "$WIFI_IF" | awk '/inet / {print $2}' | cut -d/ -f1)
    ICON=""
    TEXT="${ICON}  ${SIGNAL}% ${EXT_IP:-no-net}"
    TOOLTIP="${ICON}  ${WIFI_IF} @ ${SSID}\nLocal: ${LOCAL_IP}\nPublic: ${EXT_IP:-N/A}\nSignal: ${SIGNAL}%"
elif [[ -n "$ETH_IF" ]]; then
    LOCAL_IP=$(ip -4 addr show "$ETH_IF" | awk '/inet / {print $2}' | cut -d/ -f1)
    ICON=""
    TEXT="${ICON}  ${EXT_IP:-no-net}"
    TOOLTIP="${ICON}  ${ETH_IF}\nLocal: ${LOCAL_IP}\nPublic: ${EXT_IP:-N/A}"
else
    TEXT="Disconnected ⚠"
    TOOLTIP="Disconnected"
fi

printf '{"text":"%s","tooltip":"%s"}\n' "$TEXT" "$TOOLTIP"
