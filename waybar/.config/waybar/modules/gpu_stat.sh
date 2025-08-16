#!/usr/bin/env bash
set -euo pipefail
NVSmi="$(command -v nvidia-smi || echo /usr/bin/nvidia-smi)"

print_json(){ printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$1" "$2" "$3"; }

while :; do
  out="$("$NVSmi" --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,clocks.sm --format=csv,noheader,nounits 2>/dev/null | head -n1 || true)"
  if [ -n "$out" ]; then
    IFS=',' read -r UTIL TEMP MU MT CLK <<<"$out"
    for v in UTIL TEMP MU MT CLK; do eval "$v=\${$v//[[:space:]]/}"; done
    text="${UTIL}%"
    tip="util:${UTIL}% • temp:${TEMP}°C • vram:${MU}/${MT} MiB • core:${CLK} MHz"
    print_json "$text" "$tip" "nvidia"
  else
    print_json "N/A" "nvidia-smi not found/ready" "nvidia"
  fi
  sleep 3
done
