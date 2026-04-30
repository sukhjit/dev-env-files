#!/bin/bash

set -euo pipefail

WAYBAR_DIR="$(cd "$(dirname "$0")/.." && pwd)"
THEMES_DIR="$WAYBAR_DIR/themes"
STATE_FILE="$WAYBAR_DIR/.current-theme"

mapfile -t THEMES < <(ls -1 "$THEMES_DIR")

if [[ ${#THEMES[@]} -eq 0 ]]; then
    echo "No themes found in $THEMES_DIR" >&2
    exit 1
fi

current_theme=""
if [[ -f "$STATE_FILE" ]]; then
    current_theme=$(cat "$STATE_FILE")
fi

next_theme=""
found=0
for theme in "${THEMES[@]}"; do
    if [[ $found -eq 1 ]]; then
        next_theme="$theme"
        break
    fi
    if [[ "$theme" == "$current_theme" ]]; then
        found=1
    fi
done

# Wrap around to first theme
if [[ -z "$next_theme" ]]; then
    next_theme="${THEMES[0]}"
fi

ln -sf "$THEMES_DIR/$next_theme/config.jsonc" "$WAYBAR_DIR/config.jsonc"
ln -sf "$THEMES_DIR/$next_theme/style.css" "$WAYBAR_DIR/style.css"
echo "$next_theme" >"$STATE_FILE"

if pgrep -x waybar >/dev/null; then
    killall waybar
fi
waybar &

echo "Switched to theme: $next_theme"
