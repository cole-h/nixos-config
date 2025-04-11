{ pkgs, ... }:
{
  # https://github.com/cideM/dotfiles/blob/7c4b1d589c5263e3884af2b2a0f8f51cddc650d7/hosts/nixos/configuration.nix#L72-L79
  i18n.inputMethod.enable = true;
  i18n.inputMethod.type = "fcitx5";
  i18n.inputMethod.fcitx5.waylandFrontend = true;
  i18n.inputMethod.fcitx5.addons = with pkgs; [
    fcitx5-mozc
    fcitx5-gtk
  ];
}
