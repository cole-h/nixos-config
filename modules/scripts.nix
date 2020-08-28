{ config, ... }:

{
  home.file."scripts".source =
    config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nixpkgs/scripts";
}
