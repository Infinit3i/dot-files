#!/usr/bin/env bash

# Total established connections
TOTAL=$(ss -Htan state established 2>/dev/null | wc -l)

# Per-app breakdown via ss -tp (needs process info)
BREAKDOWN=$(ss -Htp state established 2>/dev/null \
  | grep -oP 'users:\(\("\K[^"]+' \
  | sort | uniq -c | sort -rn \
  | awk '{printf "%s %s\\n", $2, $1}')

if [[ -z "$BREAKDOWN" ]]; then
    BREAKDOWN="no process info"
fi

printf '{"text":"EST %s","tooltip":"%s"}\n' "$TOTAL" "$BREAKDOWN"
