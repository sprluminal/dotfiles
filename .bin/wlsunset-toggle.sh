#!/usr/bin/env bash

# Toggles the wlsunset instance started in config.d/daemons.conf

if pidof wlsunset >/dev/null; then
  killall wlsunset
  notify-send -u low "wlsunset" "Night light off"
else
  wlsunset -s 00:00 -S 00:00 &
  disown
  notify-send -u low "wlsunset" "Night light on"
fi
