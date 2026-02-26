#!/bin/bash
[[ -f /tmp/waybar_streamer_mode ]] && echo "" && exit 0

weather=$(curl -s 'https://wttr.in/?format=%t+%C&u')
temp=$(echo "$weather" | grep -oE '[-]?[0-9]+' | head -1)

if [ "$temp" -lt 45 ]; then
    echo "{\"text\":\"$weather\",\"class\":\"cold\"}"
elif [ "$temp" -gt 75 ]; then
    echo "{\"text\":\"$weather\",\"class\":\"hot\"}"
else
    echo "{\"text\":\"$weather\"}"
fi