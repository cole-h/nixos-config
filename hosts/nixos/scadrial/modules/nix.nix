{ config, lib, pkgs, ... }:

{
  nix = {
    settings = {
      builders-use-substitutes = true;
      secret-key-files = "/root/cache-priv-key.pem";

      trusted-users = [ "vin" ];
      substituters = [
        # "https://cache.qyliss.net"
        # "https://cole-h.cachix.org"
        # "https://nixpkgs-wayland.cachix.org"
        # "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "qyliss-x220:bZQtoCyr68idLFb8UQeDjnjitO/xAj52gOo9GoKZuog="
        "cole-h.cachix.org-1:qmEJ4uAe5tWwFxU/U5T/Nf2+wzXM3/rCP0SIGbK0dgU="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
