{ config, lib, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      desktopManager.gnome3 = {
        debug = true;
        enable = true;
      };
    };
  };

  environment.systemPackages = with pkgs;
    [
      gnome3.gnome-tweak-tool
    ];
}
