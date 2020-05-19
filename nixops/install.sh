#! /usr/bin/env nix-shell
#! nix-shell -p nixops -i bash

nixops create ./deployment.nix -d cosmere
nixops deploy

nixops ssh "${1:-scadrial}" doas -u vin bash -c '"export HOME=/home/vin &&
    mkdir -p \$HOME/workspace/vcs &&
    git clone https://github.com/rycee/home-manager \$HOME/workspace/vcs/home-manager &&
    git clone https://github.com/alacritty/alacritty \$HOME/workspace/vcs/alacritty &&
    git clone https://github.com/ajeetdsouza/zoxide \$HOME/workspace/vcs/zoxide &&
    nix-shell \$HOME/workspace/vcs/home-manager -A install"'
