{
  super,
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    spotify
  ];
}
