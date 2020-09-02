{ ... }:
let
  flake = import (fetchTarball https://github.com/edolstra/flake-compat/archive/master.tar.gz) {
    src = ./.;
  };
  hostname = with builtins; head (split "\n" (readFile /etc/hostname));
in
flake.defaultNix.nixosConfigurations.${hostname}.config
