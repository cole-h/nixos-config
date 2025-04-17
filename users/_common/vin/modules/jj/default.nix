{ config, lib, pkgs, ... }:
{
  xdg.configFile."jj/conf.d".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/users/_common/vin/modules/jj/conf.d";
}
