#!/usr/bin/env bash
set -u

CACHE="/tmp/waybar_pkg_status.json"
LOCK="/tmp/waybar_pkg_status.lock"
MAX_AGE=580  # slightly under the 600s interval

# If a recent cache exists, use it (avoids concurrent checkupdates races)
if [[ -f "$CACHE" ]]; then
  AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
  if [[ "$AGE" -lt "$MAX_AGE" ]]; then
    cat "$CACHE"
    exit 0
  fi
fi

# Use a lock so only one instance refreshes at a time
exec 9>"$LOCK"
if ! flock -n 9; then
  # Another instance is refreshing; use stale cache if available
  [[ -f "$CACHE" ]] && cat "$CACHE"
  exit 0
fi

# total installed packages
TOTAL_PKGS=$(pacman -Qq 2>/dev/null | wc -l | tr -d ' ')
TOTAL_PKGS=${TOTAL_PKGS:-0}

# repo updates (force fresh db check)
REPO_UPDATES=0
if command -v checkupdates >/dev/null 2>&1; then
  REPO_UPDATES=$(checkupdates --nocolor 2>/dev/null | wc -l | tr -d ' ')
else
  REPO_UPDATES=$(pacman -Sup --print-format '%n' 2>/dev/null | wc -l | tr -d ' ')
fi
REPO_UPDATES=${REPO_UPDATES:-0}

# aur updates
AUR_UPDATES=0
if command -v yay >/dev/null 2>&1; then
  AUR_UPDATES=$(yay -Qua 2>/dev/null | wc -l | tr -d ' ')
elif command -v paru >/dev/null 2>&1; then
  AUR_UPDATES=$(paru -Qua 2>/dev/null | wc -l | tr -d ' ')
fi
AUR_UPDATES=${AUR_UPDATES:-0}

NEED=$((REPO_UPDATES + AUR_UPDATES))

if [ "$NEED" -gt 0 ]; then
  TEXT="⬆ ${NEED}"
else
  TEXT=""
fi

# determine highest update source
MAX_SRC=$REPO_UPDATES
if [ "$AUR_UPDATES" -gt "$MAX_SRC" ]; then
  MAX_SRC=$AUR_UPDATES
fi

CLASS="normal"
if [ "$MAX_SRC" -ge 30 ]; then
  CLASS="critical"
elif [ "$MAX_SRC" -ge 10 ]; then
  CLASS="warning"
fi

TOOLTIP="Installed: ${TOTAL_PKGS}\\nRepo updates: ${REPO_UPDATES}\\nAUR updates: ${AUR_UPDATES}"
OUTPUT=$(printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$TEXT" "$TOOLTIP" "$CLASS")
echo "$OUTPUT" > "$CACHE"
echo "$OUTPUT"
exit 0