{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    waybar
    xwayland-satellite # for xwayland in niri
    swaynotificationcenter # alternative to mako
  ];

  xdg.configFile."waybar".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/users/scadrial/vin/modules/wayland/niri/waybar";
  xdg.configFile."niri".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/users/scadrial/vin/modules/wayland/niri/niri";
}
