#!/usr/bin/env bash

stream="${1-moonmoon}"

if [[ ! $(pgrep chatterino) ]]; then
    (QT_QPA_PLATFORM=wayland chatterino &>/dev/null &)
fi

stream() {
    streamlink twitch.tv/${stream}
}

trap 'exit' INT

while true
do
    stream
done
