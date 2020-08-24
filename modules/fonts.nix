{ pkgs, ... }:
let
  fonts = with pkgs; [
    noto-fonts-emoji # emoji font
    noto-fonts
    noto-fonts-cjk
    ttf_bitstream_vera
    # dejavu_fonts
    jetbrains-mono # code font
    iosevka-custom # code font [overlays]
    cantarell-fonts # REALLY nice UI font
    # liberation_ttf # like Microsoft fonts, but not
    # emojione
    joypixels # emoji font
    # gsfonts # [drvs]
    kochi-substitute # JP font
    # source-han-sans-japanese # JP font
    # sarasa-gothic # Iosevka, but Eastern [drvs]
    # san-francisco # Apple UI font [drvs]
    # inter # nice UI font
    ipafont # JP font
    # ipaexfont # JP font [drvs]
  ];
in
{
  # TODO: figure out font woes when switch to NixOS
  # https://github.com/NixOS/nixpkgs/blob/ae94e8923240f7ff7e82abf4783ef4318b8c4464/nixos/modules/config/fonts/fontconfig.nix
  # https://functor.tokyo/blog/2018-10-01-japanese-on-nixos
  # https://nixos.wiki/wiki/Fonts
  # fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fontconfig # needed for fc-{match,cache,list} binaries
  ] ++ fonts;
}
