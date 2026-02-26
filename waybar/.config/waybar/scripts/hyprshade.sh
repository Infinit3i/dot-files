#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-toggle}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hyprshade"
SEL_FILE="$CACHE_DIR/selected"
mkdir -p "$CACHE_DIR"

die() { echo "hyprshade.sh: $*" >&2; exit 1; }

command -v hyprshade >/dev/null 2>&1 || die "hyprshade not found (install hyprshade)."
command -v hyprctl   >/dev/null 2>&1 || die "hyprctl not found."

# Get list of available shaders (one per line)
list_shaders() {
  hyprshade list 2>/dev/null | sed '/^\s*$/d'
}

# Get current shader (empty if none)
current_shader() {
  hyprshade current 2>/dev/null | sed '/^\s*$/d' || true
}

# Pick a default shader if none selected yet
ensure_selected() {
  if [[ ! -s "$SEL_FILE" ]]; then
    list_shaders | head -n1 >"$SEL_FILE" || true
  fi
}

toggle() {
  local cur
  cur="$(current_shader)"
  if [[ -n "${cur:-}" ]]; then
    hyprshade off
  else
    ensure_selected
    local sel
    sel="$(cat "$SEL_FILE" 2>/dev/null || true)"
    [[ -n "${sel:-}" ]] || die "No shaders found. Put shaders where hyprshade expects them."
    hyprshade on "$sel"
  fi
}

pick_rofi() {
  command -v rofi >/dev/null 2>&1 || die "rofi not found."
  local choice
  choice="$(list_shaders | rofi -dmenu -i -p "Hyprshade")" || exit 0
  [[ -n "${choice:-}" ]] || exit 0
  printf '%s\n' "$choice" >"$SEL_FILE"
  hyprshade on "$choice"
}

status_json() {
  local cur sel txt tooltip class
  cur="$(current_shader)"
  sel="$(cat "$SEL_FILE" 2>/dev/null || true)"

  if [[ -n "${cur:-}" ]]; then
    txt=""
    tooltip="Shader: $cur"
    class="on"
  else
    txt=""
    tooltip="Shader: off\nSelected: ${sel:-none}"
    class="off"
  fi

  # JSON for Waybar if you ever switch the module to return-type json
  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
    "$txt" "${tooltip//$'\n'/\\n}" "$class"
}

case "$CMD" in
  toggle|"") toggle ;;
  rofi)      pick_rofi ;;
  status)    status_json ;;
  off)       hyprshade off ;;
  on)        ensure_selected; hyprshade on "$(cat "$SEL_FILE")" ;;
  *)         die "Usage: $0 [toggle|rofi|status|on|off]" ;;
esac