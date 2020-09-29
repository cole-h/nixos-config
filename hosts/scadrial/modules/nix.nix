{ config, lib, pkgs, ... }:

{
  nix = {
    package = lib.mkDefault pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
    '';

    trustedUsers = [ "vin" ];
    autoOptimiseStore = true;
    binaryCaches = [
      # "https://cache.qyliss.net"
      # "https://cole-h.cachix.org"
      "https://passrs.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];

    binaryCachePublicKeys = [
      "qyliss-x220:bZQtoCyr68idLFb8UQeDjnjitO/xAj52gOo9GoKZuog="
      "cole-h.cachix.org-1:qmEJ4uAe5tWwFxU/U5T/Nf2+wzXM3/rCP0SIGbK0dgU="
      "passrs.cachix.org-1:qEBRtLoyRFMZC8obhs0JjUW95PVaPYAUvixVPt6Qsa0="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };
}