#!/usr/bin/env bash
# Prints current song as a single line for Hyprlock.
# Prefers Spotify/MPD/VLC/MPV, falls back to any MPRIS player.
# Requires: playerctl

set -euo pipefail

# Order of preference (comma-separated playerctl list)
PLAYERS="spotify,mpd,vlc,mpv,chromium,google-chrome,brave,firefox,io.github.celluloid_player.Celluloid"

# Icons (needs Nerd Font / Font Awesome); swap to "♫", "▶", "⏸" if glyphs don't show
ICON_NOTE=""
ICON_PLAY=""
ICON_PAUSE=""

# If playerctl not installed, print a space (keeps layout stable) and exit
if ! command -v playerctl >/dev/null 2>&1; then
  printf " "
  exit 0
fi

# Use preferred list if any of them respond; otherwise query the first available player
CTL_ARGS=()
if playerctl -p "$PLAYERS" status >/dev/null 2>&1; then
  CTL_ARGS=(-p "$PLAYERS")
fi

state="$(playerctl "${CTL_ARGS[@]}" status 2>/dev/null | head -n1 || true)"
title="$(playerctl "${CTL_ARGS[@]}" metadata xesam:title  2>/dev/null | head -n1 || true)"
artist="$(playerctl "${CTL_ARGS[@]}" metadata xesam:artist 2>/dev/null | head -n1 || true)"

# Nothing playing? Print a space so Hyprlock doesn’t show "null"
if [[ -z "${title}" ]]; then
  printf " "
  exit 0
fi

icon="$ICON_NOTE"
case "$state" in
  Playing) icon="$ICON_PLAY" ;;
  Paused)  icon="$ICON_PAUSE" ;;
esac

# Render: " Artist — Title" or " Title" if no artist
if [[ -n "$artist" ]]; then
  printf "%s %s — %s" "$icon" "$artist" "$title"
else
  printf "%s %s" "$icon" "$title"
fi
