{ config, my, ... }:

{
  xdg.dataFile = {
    "chatterino/Settings".source = config.lib.file.mkOutOfStoreSymlink my.secrets.chatterino;
  };

  home.file = {
    ".todo".source = config.lib.file.mkOutOfStoreSymlink my.secrets.todo;
  };
}
