{ config, my, ... }:

{
  xdg.configFile = {
    "cachix/cachix.dhall".source = config.lib.file.mkOutOfStoreSymlink my.secrets."cachix.dhall";
  };

  xdg.dataFile = {
    "chatterino/Settings".source = config.lib.file.mkOutOfStoreSymlink my.secrets.chatterino;
  };

  home.file = {
    # TODO: why does this not work tho
    ".todo".source = config.lib.file.mkOutOfStoreSymlink my.secrets.todo;
    ".ssh/config".source = config.lib.file.mkOutOfStoreSymlink my.secrets.sshconfig;
  };
}
