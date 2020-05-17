{ config, ... }:

{
  home.file."scripts".source = config.lib.file.mkOutOfStoreSymlink ../scripts;
}
