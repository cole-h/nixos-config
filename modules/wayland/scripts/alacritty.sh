#!/usr/bin/env bash
focused=$(swaymsg -t get_tree | jq '.. | (.nodes? // empty)[] | select(.focused==true)')

if [[ $(jq -r ".app_id" <<< "$focused") == "Alacritty" ]]; then
  # get child pid
  pid="$(pgrep -P "$(jq '.pid' <<< "$focused")")"

  # if child isn't our shell, climb parents until it is
  while [[ -n $pid && $pid -ne 1 && $(cat /proc/"$pid"/comm) != *"fish"* ]]; do
    pid="$(ps -o ppid= -p "$pid")"
  done

  dir="$(readlink /proc/"$pid"/cwd)"

  if [[ -n $dir ]]; then
    exec alacritty --working-directory "$dir" "$@" || exec alacritty "$@"
  else
    exec alacritty "$@"
  fi
else
  exec alacritty "$@"
fi
