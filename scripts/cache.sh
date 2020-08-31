#!/usr/bin/env bash

# This script is here for both future reference on how to check that a cache
# serves a path, and to make sure cachix's 10GB limit doesn't mean it deletes
# paths still needed.

# In addition, you could use these paths here to fetch the derivations directly,
# completely circumventing the slow Nix evaluation, at the cost of
# reproducibility. Only seems useful for one-off testing or so.

# Thanks, infinisil: https://github.com/Infinisil/all-hies/blob/4b6aab017cdf96a90641dc287437685675d598da/check-cache.sh

cache="passrs"

storepaths=(
	# paths here
)

misslog=$(mktemp)

for path in ${storepaths[*]}; do
  url=$(sed -r <<< $path \
    -e 's|-.*|.narinfo|' \
    -e "s|/nix/store|https://${cache}.cachix.org|")
  {
    code=$(curl -s -o /dev/null -w "%{http_code}\n" "$url")
    case "$code" in
      200)
        echo "HIT $path"
        ;;
      *)
        echo -e "\e[01;31mMISS($code)\e[0m $path"
        echo "" >> $misslog
        ;;
    esac
  } &
done

wait

misses=$(wc -l < "$misslog")
rm "$misslog"
exit "$misses"
