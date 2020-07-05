# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  sources = import ../../nix/sources.nix;
in
{
  imports = [
    # "${sources.home-manager}/nixos"
    ~/workspace/vcs/home-manager/nixos
    ./hardware-configuration.nix
    ./modules
  ];

  # link directories doesn't work
  # environment.persistence."/media".link.directories = [
  #   "/asdf"
  # ];

  # bind files doesn't work
  # environment.persistence."/media".bind.files = [
  #   "/jkl"
  # ];

  home-manager = {
    users.vin = import ../../home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  ## nix
  nix = {
    trustedUsers = [ "vin" ];
    autoOptimiseStore = true;
    binaryCaches = [
      "https://cache.qyliss.net"
      "https://cole-h.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];

    binaryCachePublicKeys = [
      "qyliss-x220:bZQtoCyr68idLFb8UQeDjnjitO/xAj52gOo9GoKZuog="
      "cole-h.cachix.org-1:qmEJ4uAe5tWwFxU/U5T/Nf2+wzXM3/rCP0SIGbK0dgU="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
