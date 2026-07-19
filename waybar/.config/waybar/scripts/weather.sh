#!/bin/bash
# Waybar weather module.
# Pulls wttr.in's JSON feed and maps the WWO weather code to a Nerd Font
# weather glyph (nf-weather-*, U+E3xx). Codes are more stable than the
# free-text condition string, which varies in wording.

# Spring Hill, FL. Pinned to coordinates because wttr.in's geocoder mangles the
# name: "Spring+Hill,FL" lands on Bronson and the 34606 ZIP resolves to Korea.
LOCATION="28.4769,-82.5254"
CACHE="/tmp/waybar_weather.json"

json=$(curl -s --max-time 10 "https://wttr.in/${LOCATION}?format=j1")

# Fall back to the last good payload so a dropped request doesn't blank the bar.
if [ -n "$json" ] && echo "$json" | jq -e '.current_condition[0]' >/dev/null 2>&1; then
    echo "$json" > "$CACHE"
else
    [ -f "$CACHE" ] && json=$(cat "$CACHE")
fi

if [ -z "$json" ] || ! echo "$json" | jq -e '.current_condition[0]' >/dev/null 2>&1; then
    echo '{"text":"","tooltip":"Weather unavailable","class":"error"}'
    exit 0
fi

read -r code temp_f feels_f humidity wind_mph wind_dir desc uv < <(
    echo "$json" | jq -r '.current_condition[0] |
        [.weatherCode, .temp_F, .FeelsLikeF, .humidity,
         .windspeedMiles, .winddir16Point, (.weatherDesc[0].value|gsub(" ";"_")), .uvIndex]
        | @tsv'
)

sunrise=$(echo "$json" | jq -r '.weather[0].astronomy[0].sunrise')
sunset=$(echo "$json" | jq -r '.weather[0].astronomy[0].sunset')
desc=${desc//_/ }

# Day if we're between sunrise and sunset; drives the sun/moon variants.
now=$(date +%s)
rise=$(date -d "$sunrise" +%s 2>/dev/null || echo 0)
set_=$(date -d "$sunset" +%s 2>/dev/null || echo 0)
if [ "$now" -ge "$rise" ] && [ "$now" -lt "$set_" ]; then day=1; else day=0; fi

case "$code" in
    113) [ "$day" = 1 ] && icon="" || icon="" ;;                # sunny / clear
    116) [ "$day" = 1 ] && icon="" || icon="" ;;                # partly cloudy
    119|122) icon="" ;;                                               # cloudy / overcast
    143|248|260) [ "$day" = 1 ] && icon="" || icon="" ;;        # mist / fog
    176|263|266|281|284|293|296|299|302|353) \
        [ "$day" = 1 ] && icon="" || icon="" ;;                 # drizzle / light rain
    305|308|356|359) icon="" ;;                                       # heavy rain / showers
    179|182|185|227|323|326|329|332|362|365|368|371) icon="" ;;        # snow
    230|335|338) icon="" ;;                                           # blizzard / heavy snow
    311|314|317|320|350|374|377) icon="" ;;                           # sleet / freezing / ice
    200|386|389|392|395) icon="" ;;                                   # thunder
    *) icon="" ;;                                                     # n/a
esac

display="${icon} ${temp_f}°F"

printf -v tooltip '%s\nFeels like: %s°F\nHumidity: %s%%\nWind: %s mph %s\nUV index: %s\nSunrise: %s  Sunset: %s' \
    "$desc" "$feels_f" "$humidity" "$wind_mph" "$wind_dir" "$uv" "$sunrise" "$sunset"

if [ "$temp_f" -gt 72 ]; then
    class="hot"
elif [ "$temp_f" -lt 40 ]; then
    class="cold"
else
    class=""
fi

jq -cn --arg text "$display" --arg tooltip "$tooltip" --arg class "$class" \
    '{text:$text, tooltip:$tooltip, class:$class}'
