{ pkgs, ... }:
{
  i18n = {
    # https://github.com/cideM/dotfiles/blob/7c4b1d589c5263e3884af2b2a0f8f51cddc650d7/hosts/nixos/configuration.nix#L72-L79
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };

    # https://discourse.nixos.org/t/wayland-and-fcitx5-japanese-input/11488/4
    # inputMethod = {
    #   enabled = "ibus";
    #   ibus.engines = with pkgs.ibus-engines; [ mozc ];
    # };
  };
}
