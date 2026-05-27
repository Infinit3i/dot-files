#!/usr/bin/env bash

# Total established connections (all users)
TOTAL=$(ss -Htan state established 2>/dev/null | wc -l)

# Per-app breakdown — try sudo first to see all users' process info
SS_OUT=$(sudo -n /usr/bin/ss -Htp state established 2>/dev/null) \
  || SS_OUT=$(ss -Htp state established 2>/dev/null)

BREAKDOWN=$(echo "$SS_OUT" \
  | grep -oP 'users:\(\("\K[^"]+' \
  | sort | uniq -c | sort -rn \
  | awk '{printf "%s %s\\n", $2, $1}')

# Account for sockets without visible process info (other users/root)
LISTED=$(printf '%b' "$BREAKDOWN" | awk '{s+=$2} END{print s+0}')
OTHER=$((TOTAL - LISTED))
if [[ $OTHER -gt 0 ]]; then
    BREAKDOWN+="(other) $OTHER\\n"
fi

if [[ -z "$BREAKDOWN" ]]; then
    BREAKDOWN="no process info"
fi

printf '{"text":"EST %s","tooltip":"%s"}\n' "$TOTAL" "$BREAKDOWN"
