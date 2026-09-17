#!/usr/bin/env bash

# Power menu, styled with ~/.config/rofi/themes/powermenu.rasi
# Bound to the waybar launcher's right-click.

lock="swaylock"
suspend="systemctl suspend"
logout="loginctl terminate-user $USER"

options=(
  "LOCK"
  "SUSPEND"
  "LOG-OUT"
  "RESTART"
  "POWER-OFF"
)

chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -theme-str '@import "~/.config/rofi/themes/powermenu.rasi"')

case "$chosen" in
  "LOCK") eval "$lock" ;;
  "SUSPEND") eval "$lock && $suspend" ;;
  "LOG-OUT") eval "$logout" ;;
  "RESTART") systemctl reboot ;;
  "POWER-OFF") systemctl poweroff ;;
  *) exit 1 ;;
esac
