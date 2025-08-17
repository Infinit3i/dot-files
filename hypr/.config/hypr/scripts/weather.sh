#!/usr/bin/env bash
set -euo pipefail

CITY_PRIMARY="Jaksonville,NC"      # wttr’s goofy spelling you used
CITY_FALLBACK="Jacksonville,NC"    # real spelling as fallback

fetch() { /usr/bin/curl -fsS --connect-timeout 2 --max-time 2 "https://wttr.in/$1?format=1&u" || true; }

while true; do
    out="$(fetch "$CITY_PRIMARY")"
    if [ -z "$out" ] || [[ "$out" =~ (Unknown|ERROR) ]]; then
      out="$(fetch "$CITY_FALLBACK")"
    fi

    # Always print *something* so Hyprlock doesn’t render “null”
    printf "%s\n" "${out:- }"

    # every hour
    sleep 3600
done
