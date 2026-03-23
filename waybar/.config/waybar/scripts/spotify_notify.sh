#!/bin/bash

# Watches for Spotify track changes and sends a notification with album art

ART_PATH="/tmp/spotify_album_art.jpg"

playerctl --player=spotify --follow metadata --format '{{artist}} - {{title}}' 2>/dev/null | while read -r track; do
  if [[ -n "$track" ]]; then
    art_url=$(playerctl --player=spotify metadata mpris:artUrl 2>/dev/null)
    artist=$(playerctl --player=spotify metadata artist 2>/dev/null)
    title=$(playerctl --player=spotify metadata title 2>/dev/null)

    if [[ -n "$art_url" ]]; then
      curl -s -o "$ART_PATH" "$art_url"
      notify-send -a "Spotify" -i "$ART_PATH" "$title" "$artist"
    else
      notify-send -a "Spotify" "$title" "$artist"
    fi
  fi
done
