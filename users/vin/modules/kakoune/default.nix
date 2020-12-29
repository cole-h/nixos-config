{ config, ... }:
let
  here = "${config.home.homeDirectory}/flake/users/${config.home.username}/modules/kakoune";
in
{
  xdg.configFile."kak".source = config.lib.file.mkOutOfStoreSymlink "${here}/config";
  xdg.configFile."kak-lsp/kak-lsp.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${here}/kak-lsp.toml";
}
