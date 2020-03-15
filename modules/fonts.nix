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
    liberation_ttf # like Microsoft fonts, but not
    # emojione
    # joypixels # emoji font
    # gsfonts # [drvs]
    kochi-substitute
    source-han-sans-japanese # JP font
    sarasa-gothic # Iosevka, but Eastern [drvs]
    # san-francisco # Apple UI font [drvs]
    # inter # nice UI font
    ipafont
    # ipaexfont # JP font [drvs]
  ];
in
{
  # TODO: figure out font woes when switch to NixOS
  # https://github.com/NixOS/nixpkgs/blob/ae94e8923240f7ff7e82abf4783ef4318b8c4464/nixos/modules/config/fonts/fontconfig.nix
  # https://functor.tokyo/blog/2018-10-01-japanese-on-nixos
  # https://nixos.wiki/wiki/Fonts
  # fonts.fontconfig.enable = false;

  home = {
    packages = with pkgs; [
      fontconfig # needed for fc-{match,cache,list} binaries
    ] ++ fonts;

    sessionVariables = {
      # FONTCONFIG_FILE = pkgs.makeFontsConf {
      #   fontDirectories = [
      #     #
      #   ] ++ fonts;
      # };
      # FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
    };
  };

  # TODO: look at all of my font.d files from Arch
  # xdg.configFile."fontconfig/conf.d/75-noto-color-emoji.conf".text = ''
  #   <?xml version="1.0" encoding="UTF-8"?> <!DOCTYPE fontconfig SYSTEM "fonts.dtd"> <fontconfig>

  #   <!-- Add generic family. -->
  #   <match target="pattern">
  #       <test qual="any" name="family"><string>emoji</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <!-- This adds Noto Color Emoji as a final fallback font for the default font families. -->
  #   <match target="pattern">
  #       <test name="family"><string>sans</string></test>
  #       <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test name="family"><string>serif</string></test>
  #       <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test name="family"><string>sans-serif</string></test>
  #       <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test name="family"><string>monospace</string></test>
  #       <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <!-- Block Symbola from the list of fallback fonts. -->
  #   <selectfont>
  #       <rejectfont>
  #           <pattern>
  #               <patelt name="family">
  #                   <string>Symbola</string>
  #               </patelt>
  #           </pattern>
  #       </rejectfont>
  #   </selectfont>

  #   <!-- Use Noto Color Emoji when other popular fonts are being specifically requested. -->
  #   <match target="pattern">
  #       <test qual="any" name="family"><string>Apple Color Emoji</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>Segoe UI Emoji</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>Segoe UI Symbol</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>Android Emoji</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>Twitter Color Emoji</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>Twemoji</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>Twemoji Mozilla</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>TwemojiMozilla</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>EmojiTwo</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>Emoji Two</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>EmojiSymbols</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   <match target="pattern">
  #       <test qual="any" name="family"><string>Symbola</string></test>
  #       <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  #   </match>

  #   </fontconfig>
  # '';
}
