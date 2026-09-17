#!/bin/bash
# set-contrast.sh — switch the rice between Gruvbox's three official
# background-contrast levels: hard, medium, soft.
#
# Only one thing ever changes: which shade of near-black is used as the
# base background (bg0). Every other colour in the palette — bg1-4,
# fg0-4, and all the red/green/yellow/blue/purple/aqua/orange accents —
# is fixed by the Gruvbox spec and untouched by this script.
#
# Run manually, whenever you feel like it:
#   .bin/set-contrast.sh hard      (default — very dark, punchy borders)
#   .bin/set-contrast.sh medium    (Gruvbox's own "normal" bg0)
#   .bin/set-contrast.sh soft      (gentler, less eye strain at night)
#   .bin/set-contrast.sh           (prints the current level, changes nothing)
#
# Reload sway (mod+shift+c or `swaymsg reload`) and restart waybar/kitty
# afterwards to see it take effect. rofi and swaylock pick it up on their
# next launch automatically.

set -euo pipefail

SWAY_COLORS="$HOME/.config/sway/config.d/colors.conf"
WAYBAR_COLORS="$HOME/.config/waybar/colors.css"
ROFI_COLORS="$HOME/.config/rofi/themes/colors.rasi"
KITTY_COLORS="$HOME/.config/kitty/colors.conf"
SWAYLOCK_CONFIG="$HOME/.config/swaylock/config"

current_level() {
  grep -m1 'Current contrast:' "$SWAY_COLORS" 2>/dev/null | sed 's/.*Current contrast: *//'
}

LEVEL="${1:-}"
if [[ -z "$LEVEL" ]]; then
  echo "Current contrast: $(current_level || echo unknown)"
  echo "Usage: $0 [hard|medium|soft]"
  exit 0
fi

case "$LEVEL" in
  hard)   HEX="1d2021" ;;
  medium) HEX="282828" ;;
  soft)   HEX="32302f" ;;
  *)
    echo "Unknown contrast level '$LEVEL' — use hard, medium, or soft." >&2
    exit 1
    ;;
esac

for f in "$SWAY_COLORS" "$WAYBAR_COLORS" "$ROFI_COLORS" "$KITTY_COLORS" "$SWAYLOCK_CONFIG"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing $f — is the waybar/rofi/kitty/swaylock config in place?" >&2
    exit 1
  fi
done

# sway
sed -i "s/^\(set \\\$bg0 *\)#[0-9a-f]\{6\}/\1#${HEX}/" "$SWAY_COLORS"
sed -i "s/^\(# Current contrast: \).*/\1${LEVEL}/" "$SWAY_COLORS"

# waybar
sed -i "s/^\(@define-color bg0 *\)#[0-9a-f]\{6\};/\1#${HEX};/" "$WAYBAR_COLORS"
sed -i "s/\(Current contrast: \).*\( \*\/\)/\1${LEVEL}\2/" "$WAYBAR_COLORS"

# rofi
sed -i "s/^\(  bg0: *\)#[0-9a-f]\{6\};/\1#${HEX};/" "$ROFI_COLORS"
sed -i "s/\(Current contrast: \).*\( \*\/\)/\1${LEVEL}\2/" "$ROFI_COLORS"

# kitty (background, selection_foreground, and ANSI color0 all track bg0)
sed -i "s/^\(background *\)#[0-9a-f]\{6\}/\1#${HEX}/" "$KITTY_COLORS"
sed -i "s/^\(selection_foreground *\)#[0-9a-f]\{6\}/\1#${HEX}/" "$KITTY_COLORS"
sed -i "s/^\(color0  *\)#[0-9a-f]\{6\}/\1#${HEX}/" "$KITTY_COLORS"
sed -i "s/^\(# Current contrast: \).*/\1${LEVEL}/" "$KITTY_COLORS"

# swaylock (no variables here — the two backdrop keys get the literal hex)
sed -i "s/^inside-color=[0-9a-f]\{6\}/inside-color=${HEX}/" "$SWAYLOCK_CONFIG"
sed -i "s/^layout-bg-color=[0-9a-f]\{6\}/layout-bg-color=${HEX}/" "$SWAYLOCK_CONFIG"

echo "Contrast set to '${LEVEL}' (bg0 = #${HEX})."
echo "Reload sway and restart waybar/kitty to see it everywhere."
