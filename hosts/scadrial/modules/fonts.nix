{ pkgs, ... }:

{
  fonts = {
    fontconfig = {
      defaultFonts = {
        emoji = [ "Twitter Color Emoji" ];
        serif = [ "Bitstream Vera Serif" ];
        sansSerif = [ "Bitstream Vera Sans" ];
        monospace = [ "Bitstream Vera Sans Mono" ];
      };
    };

    fonts = with pkgs; [
      ttf_bitstream_vera
      font-awesome_4
      unifont

      noto-fonts-emoji # emoji font
      noto-fonts
      noto-fonts-cjk
      ttf_bitstream_vera
      # dejavu_fonts
      jetbrains-mono # code font
      cantarell-fonts # REALLY nice UI font
      # liberation_ttf # like Microsoft fonts, but not
      kochi-substitute # JP font
      # source-han-sans-japanese # JP font
      # inter # nice UI font
      ipafont # JP font
      # ipaexfont # JP font [drvs]
    ];
  };
}
