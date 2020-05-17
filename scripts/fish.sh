#!/bin/bash
# Courtesy of @chrisduerr

fish_len=7
last_col=$(($(tput cols) - fish_len - 1))

for c in $(seq $last_col -1 0); do
    if [[ $((c % 2)) == 0 ]]; then
        echo -ne "\e[${c}G<°)))彡"
    else
        echo -ne "\e[${c}G<°)))ミ"
    fi
    sleep .1
done
echo
