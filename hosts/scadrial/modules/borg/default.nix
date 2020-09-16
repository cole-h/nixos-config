{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./prometheus.nix
      ./ofborg.nix
    ];
}
