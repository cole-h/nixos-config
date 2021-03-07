#!/usr/bin/env bash

set -x

mapfile -t arr < <(nix eval --json .#inputs \
  | jq -r '. | to_entries | map ("--update-input \(.key)") | join(" ")')

nix flake lock ${arr[@]} \
  --commit-lock-file
