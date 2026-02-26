#!/usr/bin/env bash
[[ -f /tmp/waybar_streamer_mode ]] && echo "" && exit 0

curl -fsS --max-time 2 https://api.ipify.org 2>/dev/null || echo "no-net"
