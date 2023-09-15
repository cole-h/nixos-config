{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    ttf_bitstream_vera
    font-awesome_4
    unifont

    noto-fonts-color-emoji # emoji font
    noto-fonts
    noto-fonts-cjk-sans
    ttf_bitstream_vera
    # dejavu_fonts
    jetbrains-mono # code font
    # liberation_ttf # like Microsoft fonts, but not
    kochi-substitute # JP font
    # source-han-sans-japanese # JP font
    # inter # nice UI font
    ipafont # JP font
    # ipaexfont # JP font [drvs]
  ];
}
