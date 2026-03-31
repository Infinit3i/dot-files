#!/bin/bash

weather=$(curl -s 'https://wttr.in/?format=%t+%C')
temp_c=$(echo "$weather" | grep -oE '[-+]?[0-9]+' | head -1)
condition=$(echo "$weather" | sed 's/^[^ ]* //')

# Convert Celsius to Fahrenheit
temp_f=$(( temp_c * 9 / 5 + 32 ))

display="+${temp_f}°F ${condition}"
[ "$temp_f" -lt 0 ] && display="${temp_f}°F ${condition}"

if [ "$temp_f" -lt 45 ]; then
    echo "{\"text\":\"$display\",\"class\":\"cold\"}"
elif [ "$temp_f" -gt 75 ]; then
    echo "{\"text\":\"$display\",\"class\":\"hot\"}"
else
    echo "{\"text\":\"$display\"}"
fi
