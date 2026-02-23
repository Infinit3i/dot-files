#!/usr/bin/env bash
set -u

# total installed packages
TOTAL_PKGS=$(pacman -Qq 2>/dev/null | wc -l | tr -d ' ')
TOTAL_PKGS=${TOTAL_PKGS:-0}

# repo updates
REPO_UPDATES=0
if command -v checkupdates >/dev/null 2>&1; then
  REPO_UPDATES=$(checkupdates 2>/dev/null | awk 'END{print NR+0}')
fi

# aur updates
AUR_UPDATES=0
if command -v yay >/dev/null 2>&1; then
  AUR_UPDATES=$(yay -Qua 2>/dev/null | awk 'END{print NR+0}')
elif command -v paru >/dev/null 2>&1; then
  AUR_UPDATES=$(paru -Qua 2>/dev/null | awk 'END{print NR+0}')
fi

NEED=$((REPO_UPDATES + AUR_UPDATES))

if [ "$NEED" -gt 0 ]; then
  TEXT="⬆ ${REPO_UPDATES} | PKG ${TOTAL_PKGS} | AUR ${AUR_UPDATES}"
else
  TEXT="PKG ${TOTAL_PKGS}"
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

TOOLTIP="Repo updates: ${REPO_UPDATES}\\nAUR updates: ${AUR_UPDATES}\\nInstalled packages: ${TOTAL_PKGS}"
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$TEXT" "$TOOLTIP" "$CLASS"
exit 0