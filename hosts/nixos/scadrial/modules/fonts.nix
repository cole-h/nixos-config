{ pkgs, ... }:

{
  fonts.fontconfig = {
    defaultFonts = {
      emoji = [ "Twitter Color Emoji" ];
      serif = [ "Bitstream Vera Serif" ];
      sansSerif = [ "Bitstream Vera Sans" ];
      monospace = [ "Bitstream Vera Sans Mono" ];
    };
  };
}
