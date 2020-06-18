{ config, ... }:
with config;

{
  xdg.configFile = {
    "cachix/cachix.dhall".source = lib.file.mkOutOfStoreSymlink my.secrets."cachix.dhall";
  };

  xdg.dataFile = {
    "chatterino/Settings".source = lib.file.mkOutOfStoreSymlink my.secrets.chatterino;
  };

  home.file = {
    ".todo".source = lib.file.mkOutOfStoreSymlink my.secrets.todo;
    ".ssh/config".source = lib.file.mkOutOfStoreSymlink my.secrets.sshconfig;
  };
}
