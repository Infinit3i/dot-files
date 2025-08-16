# ~/.config/hypr/scripts/capslock.sh
#!/usr/bin/env bash
# Prints "CAPS" when Caps Lock is on, otherwise prints nothing.
for led in /sys/class/leds/*::capslock/brightness; do
  [ -r "$led" ] && read -r v < "$led" && [ "$v" = "1" ] && { printf "CAPS"; exit 0; }
done
printf ""
