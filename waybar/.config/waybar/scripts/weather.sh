#!/bin/bash

weather=$(curl -s 'https://wttr.in/Dumfries,VA?format=%t+%C&u')
temp_f=$(echo "$weather" | grep -oE '[-+]?[0-9]+' | head -1)
temp_f=${temp_f#+}

display="${temp_f}°F"

if [ "$temp_f" -gt 60 ]; then
    echo "{\"text\":\"$display\",\"class\":\"hot\"}"
elif [ "$temp_f" -lt 45 ]; then
    echo "{\"text\":\"$display\",\"class\":\"cold\"}"
else
    echo "{\"text\":\"$display\"}"
fi
