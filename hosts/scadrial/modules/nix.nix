{ config, lib, pkgs, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
      secret-key-files = /root/cache-priv-key.pem
    '';

    trustedUsers = [ "vin" ];
    autoOptimiseStore = true;
    binaryCaches = [
      # "https://cache.qyliss.net"
      # "https://cole-h.cachix.org"
      "https://passrs.cachix.org"
      "https://alacritty.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://nix-community.cachix.org"
    ];

    binaryCachePublicKeys = [
      "qyliss-x220:bZQtoCyr68idLFb8UQeDjnjitO/xAj52gOo9GoKZuog="
      "cole-h.cachix.org-1:qmEJ4uAe5tWwFxU/U5T/Nf2+wzXM3/rCP0SIGbK0dgU="
      "passrs.cachix.org-1:qEBRtLoyRFMZC8obhs0JjUW95PVaPYAUvixVPt6Qsa0="
      "alacritty.cachix.org-1:/qirsw0af1Mf5vshRf3mWVuE/kCB6vZn6tYOkd4nWsU="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
