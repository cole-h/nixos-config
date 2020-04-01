{ lib, pkgs, ... }:
with lib;
let
  mkOptionStr = value: mkOption {
    type = types.str;
    default = value;
  };
in
{
  options.my = {
    wallpaper = mkOptionStr (toString ./wallpaper.png);
  };
}
