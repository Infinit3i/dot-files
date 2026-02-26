#!/usr/bin/env bash
[[ -f /tmp/waybar_streamer_mode ]] && echo "" && exit 0

ss -Htan state established 2>/dev/null | wc -l
