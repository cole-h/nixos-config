#!/usr/bin/env bash
# https://apidocs.imgur.com/

. ~/.config/imgur

if [ "$1" = "refresh" ]; then
    res="$(curl --location --request POST 'https://api.imgur.com/oauth2/token' \
        --form "refresh_token=$refresh_token" \
        --form "client_id=$client_id" \
        --form "client_secret=$client_secret" \
        --form "grant_type=refresh_token")"
    echo -e "$res\n"

    new_auth="$(jq -r '.access_token' <<< $res)"
    new_refresh="$(jq -r '.refresh_token' <<< $res)"

    sed -i "s,\(auth='Authorization: Bearer\) .*',\1 $new_auth'," ~/.config/imgur
    sed -i "s,\(refresh_token=\)'.*',\1'$new_refresh'," ~/.config/imgur
else
    res="$(curl --location --request POST 'https://api.imgur.com/3/image' \
        --header "$auth" --data-binary @-)"
    echo -e "$res\n"

    id="$(jq -r '.data.id' <<< $res)"
    res="$(curl --location --request POST "https://api.imgur.com/3/album/$albumid/add" \
        --header "$auth" --form "ids[]=$id")"
    echo -e "$res\n"

    echo "https://i.imgur.com/$id.png" | wl-copy --trim-newline
fi
