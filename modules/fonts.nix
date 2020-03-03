{ config, lib, pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fontconfig # needed for fc-{match,cache,list} binaries

    noto-fonts-emoji # emoji font
    # noto-fonts-cjk # JP font
    iosevka-custom # code font [overlays]
    sarasa-gothic # Iosevka, but Eastern [pkgs]
    jetbrains-mono # code font
    inter # nice UI font
    ttf_bitstream_vera
    liberation_ttf # like Microsoft fonts, but not
    source-han-sans-japanese # JP font
    san-francisco # Apple UI font [pkgs]
  ];
}
