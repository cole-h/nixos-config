#!/usr/bin/env bash
# https://apidocs.imgur.com/

. ~/.config/imgur

if [ "$1" = "refresh" ]; then
    res="$(curl --location --request POST 'https://api.imgur.com/oauth2/token' \
        --form "refresh_token=$refresh_token" \
        --form "client_id=$client_id" \
        --form "client_secret=$client_secret" \
        --form "grant_type=refresh_token")"
    echo -e "$res" | tee -a ~/imgur.log

    new_auth="$(jq -r '.access_token' <<< $res)"
    new_refresh="$(jq -r '.refresh_token' <<< $res)"

    sed -i "s,\(auth='Authorization: Bearer\) .*',\1 $new_auth'," ~/.config/imgur
    sed -i "s,\(refresh_token=\)'.*',\1'$new_refresh'," ~/.config/imgur
else
    res="$(curl --location --request POST 'https://api.imgur.com/3/image' \
        --header "$auth" --data-binary @-)"
    echo "$res"

    url="$(jq -r '.data.link' <<< $res)"
    id="$(jq -r '.data.id' <<< $res)"
    res="$(curl --location --request POST "https://api.imgur.com/3/album/$albumid/add" \
        --header "$auth" --form "ids[]=$id")"
    echo "$res"


    echo "$url" | tee -a ~/imgur.log | wl-copy --trim-newline
fi
