#!/usr/bin/env bash
RECT="$(slurp -w 2 -c a3a3a3 -b 00000000 -f "%w %h %x %y")" || exit 1

IFS=' ' read -r W H X Y <<< "$RECT"

if [[ "$W" -gt "1" && "$H" -gt "1" ]]; then
  (exec alacritty --class "drawfloat" &)

  swaymsg -t subscribe -m '[ "window" ]' | while read -r event; do
    if [ "$(jq -r ".container.app_id" <<< "$event")" == "drawfloat" ]; then
      # set opacity to 1 to avoid flickering when changing side
      swaymsg [app_id="drawfloat"] floating enable, resize set "$W" "$H", \
        move absolute position "$X" "$Y", opacity 1
      break
    fi
  done
fi
