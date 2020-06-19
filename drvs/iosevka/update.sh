#! /usr/bin/env nix-shell
#! nix-shell -p nodePackages.node2nix -i bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

node2nix --nodejs-12
