#!/usr/bin/env bash

stream="${1-moonmoon}"

if [[ ! $(pgrep chatterino) ]]; then
    (chatterino &>/dev/null &)
        # ~/workspace/git/chatterino2/build/bin/chatterino &>/dev/null &)
fi

stream() {
    streamlink twitch.tv/${stream}
}

# stream() {
#     (streamlink twitch.tv/${stream} &)
#     # (env WAYLAND_DEBUG=client mpv https://twitch.tv/${stream} &)
#     while [[ ! $(pgrep mpv) ]]
#     do
#         sleep 1
#     done

#     sleep 5

#     while IFS=' ' \
#         var=("${(@f)$(swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.pid) | .app_id')}") # TODO
#     do
#         if [[ ${var[(ie)mpv]} -gt ${#var} ]]; then
#             pkill mpv
#             return
#         fi
#         sleep 1
#     done
# }

trap 'exit' INT

while true
do
    stream
done
