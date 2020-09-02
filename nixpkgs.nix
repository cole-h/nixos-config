let
  flake = import (fetchTarball https://github.com/edolstra/flake-compat/archive/master.tar.gz) {
    src = ./.;
  };
in
flake.defaultNix.legacyPackages.${builtins.currentSystem}
