{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    mako # notifications
  ];

  xdg.configFile = {
    "mako/config".text =
      let
        homeIcons = "${config.home.homeDirectory}/.nix-profile/share/icons/hicolor";
        homePixmaps = "${config.home.homeDirectory}/.nix-profile/share/pixmaps";
        systemIcons = "/run/current-system/sw/share/icons/hicolor";
        systemPixmaps = "/run/current-system/sw/share/pixmaps";
      in
      ''
        layer=overlay
        anchor=top-center
        width=400
        default-timeout=15000
        icon-path=${homeIcons}:${systemIcons}:${homePixmaps}:${systemPixmaps}

        [mode=dnd]
        invisible=1
      '';
  };
}
