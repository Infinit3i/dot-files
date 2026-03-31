#!/usr/bin/env bash
set -euo pipefail

CITY_PRIMARY="Jaksonville,NC"      # wttr's goofy spelling you used
CITY_FALLBACK="Jacksonville,NC"    # real spelling as fallback

fetch() {
    raw=$(/usr/bin/curl -fsS --connect-timeout 2 --max-time 2 "https://wttr.in/$1?format=1" || true)
    if [ -z "$raw" ] || [[ "$raw" =~ (Unknown|ERROR) ]]; then
        echo ""
        return
    fi
    # Extract celsius temp, convert to fahrenheit
    temp_c=$(echo "$raw" | grep -oE '[-+]?[0-9]+' | head -1)
    emoji=$(echo "$raw" | sed 's/ *[+-]\?[0-9].*$//')
    if [ -n "$temp_c" ]; then
        temp_f=$(( temp_c * 9 / 5 + 32 ))
        echo "${emoji} ${temp_f}°F"
    else
        echo "$raw"
    fi
}

while true; do
    out="$(fetch "$CITY_PRIMARY")"
    if [ -z "$out" ]; then
        out="$(fetch "$CITY_FALLBACK")"
    fi

    # Always print *something* so Hyprlock doesn't render "null"
    printf "%s\n" "${out:- }"

    # every hour
    sleep 3600
done
