{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fontconfig # needed for fc-{match,cache,list} binaries

    ipaexfont # JP font [drvs]
    jetbrains-mono # code font
    emojione
    ttf_bitstream_vera
    liberation_ttf # like Microsoft fonts, but not
    # noto-fonts-emoji # emoji font
    # noto-fonts-cjk # JP font
    # iosevka-custom # code font [overlays]
    # sarasa-gothic # Iosevka, but Eastern [drvs]
    # source-han-sans-japanese # JP font
    # san-francisco # Apple UI font [drvs]
    inter # nice UI font
  ];
}
