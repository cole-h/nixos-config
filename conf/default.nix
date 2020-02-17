{ config, pkgs, lib, ... }:

{
  imports = [
    ./general.nix
    ./fish.nix
    ./mpv.nix
    ./fonts.nix # contains fonts to import
  ];
}
