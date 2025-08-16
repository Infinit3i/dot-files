#!/usr/bin/env bash
# net_speed.sh — Waybar download meter: "current / max"
# Usage:
#   net_speed.sh [IFACE]          # stream current / max (tail mode)
#   net_speed.sh refresh [IFACE]  # run a speed test once and cache the max
#
# Max source priority:
#   1) Cached (~/.cache/net_max_down_mbps)
#   2) NIC link speed (/sys/class/net/$IFACE/speed)
#   3) ethtool parsing (if /sys entry missing)

set -euo pipefail

CACHE="${HOME}/.cache/net_max_down_mbps"

has() { command -v "$1" >/dev/null 2>&1; }

detect_iface() {
  ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}'
}

human_bits() {  # bps -> bps/Kbps/Mbps/Gbps (SI, 1000 base)
  local bps="$1"
  if   (( bps < 1000 ));        then printf "%d bps" "$bps"
  elif (( bps < 1000000 ));     then awk -v x="$bps" 'BEGIN{printf "%.1f Kbps", x/1000}'
  elif (( bps < 1000000000 ));  then awk -v x="$bps" 'BEGIN{printf "%.1f Mbps", x/1000000}'
  else                               awk -v x="$bps" 'BEGIN{printf "%.2f Gbps", x/1000000000}'
  fi
}

link_speed_mbps() {
  local ifc="$1" sp
  if [ -r "/sys/class/net/$ifc/speed" ]; then
    read -r sp < "/sys/class/net/$ifc/speed" || true
    [[ "$sp" =~ ^[0-9]+$ ]] && echo "$sp" && return
  fi
  if has ethtool; then
    sp="$(ethtool "$ifc" 2>/dev/null | awk -F'[: ]+' '/Speed:/{print $3}' | tr -d '[:alpha:]/')"
    [[ "$sp" =~ ^[0-9.]+$ ]] && echo "${sp%.*}" && return
  fi
  echo 0
}

refresh_max() {
  local ifc="$1"
  # Prefer speedtest-cli (python). Fall back to Ookla 'speedtest' if present.
  local mbps=""
  if has speedtest-cli; then
    # Parses "Download: 123.45 Mbit/s"
    local ln
    ln="$(speedtest-cli --simple 2>/dev/null | awk -F': *' '/^Download:/{print $2}' || true)"
    if [ -n "$ln" ]; then
      # expect "<num> <unit>"
      local num unit
      num="$(awk '{print $1}' <<<"$ln")"
      unit="$(awk '{print $2}' <<<"$ln" | tr '[:upper:]' '[:lower:]')"
      case "$unit" in
        mbit/s|mbps) mbps="$num" ;;
        gbit/s|gbps) awk -v n="$num" 'BEGIN{printf "%.1f", n*1000}' | read -r mbps ;;
        kbit/s|kbps) awk -v n="$num" 'BEGIN{printf "%.1f", n/1000}'  | read -r mbps ;;
      esac
    fi
  elif has speedtest; then
    # Ookla CLI prints "Download: 123.45 Mbps"
    local num
    num="$(speedtest -f human 2>/dev/null | awk '/^Download:/{print $2}' || true)"
    [ -n "$num" ] && mbps="$num"
  fi

  if [ -z "$mbps" ]; then
    # fallback: NIC link speed
    mbps="$(link_speed_mbps "$ifc")"
  fi

  if [[ "$mbps" =~ ^[0-9.]+$ ]] && (( $(awk -v x="$mbps" 'BEGIN{print (x>0)}') )); then
    printf "%s\n" "$mbps" > "$CACHE"
  fi
}

# --- entry points ---
if [[ "${1:-}" == "refresh" ]]; then
  ifc="${2:-$(detect_iface)}"
  [ -z "$ifc" ] && exit 1
  refresh_max "$ifc"
  exit 0
fi

IFACE="${1:-$(detect_iface)}"
[ -z "$IFACE" ] && IFACE="enp0s31f6"   # fallback if detection fails

# Initialize max if missing (non-blocking: try link first)
if [ ! -s "$CACHE" ]; then
  ms="$(link_speed_mbps "$IFACE")"
  [ "$ms" != "0" ] && printf "%s\n" "$ms" > "$CACHE"
fi

# Stream current / max
prev_rx=$(cat "/sys/class/net/$IFACE/statistics/rx_bytes" 2>/dev/null || echo 0)
while sleep 1; do
  cur_rx=$(cat "/sys/class/net/$IFACE/statistics/rx_bytes" 2>/dev/null || echo 0)
  bps=$(( (cur_rx - prev_rx) * 8 ))
  prev_rx="$cur_rx"

  # current pretty
  cur_str="$(human_bits "$bps")"

  # max pretty
  max_mbps=""; [ -r "$CACHE" ] && read -r max_mbps < "$CACHE" || true
  if [[ ! "$max_mbps" =~ ^[0-9.]+$ ]] || [ -z "$max_mbps" ]; then
    max_mbps="$(link_speed_mbps "$IFACE")"
  fi
  if [ -n "$max_mbps" ] && [ "$max_mbps" != "0" ]; then
    max_str="$(awk -v m="$max_mbps" 'BEGIN{printf "%.0f Mbps", m}')"
  else
    max_str="?"
  fi

  printf "%s / %s\n" "$cur_str" "$max_str"
done
