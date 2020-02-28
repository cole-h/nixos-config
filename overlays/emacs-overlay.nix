# let
#   rev = "7713a6d5cc90c0ef87f850ca63a7455986208927";
#   emacs-overlay = import (builtins.fetchTarball {
#     url =
#       "https://github.com/nix-community/emacs-overlay/archive/${rev}.tar.gz";
#     sha256 = "0zaaksqdjbz3mk1z0rivs835w7yj3vzyw86qp49784drsarmdajd";
#   });
# in emacs-overlay

import (builtins.fetchTarball {
  url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
})
