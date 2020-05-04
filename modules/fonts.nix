{ pkgs, ... }:
let
  fonts = with pkgs; [
    noto-fonts-emoji # emoji font
    noto-fonts
    noto-fonts-cjk
    ttf_bitstream_vera
    # dejavu_fonts
    # jetbrains-mono # code font
    iosevka-custom # code font [overlays]
    cantarell-fonts # REALLY nice UI font
    liberation_ttf # like Microsoft fonts, but not
    # emojione
    # joypixels # emoji font
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
  fonts.fontconfig.enable = true;

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
  # TODO: make fallback work nicely (JP fallback, etc)
  xdg.configFile."fontconfig/fonts.conf".text = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
    <fontconfig>

     <match target="font">
        <test name="family" compare="eq">
            <string>Roboto</string>
        </test>
        <edit name="family" mode="assign_replace">
          <string>Roboto</string>
        </edit>
        <edit name="family" mode="append_last">
          <string>serif</string>
        </edit>
      </match>

      <!-- TODO: replace Roboto with my UI fonts -->
      <match>
        <test qual="any" name="family">
            <string>serif</string>
        </test>
        <edit name="family" mode="prepend_first">
          <string>Roboto</string>
        </edit>
        <edit name="family" mode="prepend_first">
          <string>Noto Color Emoji</string>
        </edit>
      </match>

      <match target="font">
        <test name="family" compare="eq">
            <string>Roboto</string>
        </test>
        <edit name="family" mode="assign_replace">
          <string>Roboto</string>
        </edit>
        <edit name="family" mode="append_last">
          <string>sans-serif</string>
        </edit>
      </match>

      <match target="pattern">
        <test qual="any" name="family">
            <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend_first">
          <string>Roboto</string>
        </edit>
        <edit name="family" mode="prepend_first">
          <string>Noto Color Emoji</string>
        </edit>
      </match>

      <match target="font">
        <test name="family" compare="eq">
            <string>Iosevka Custom Extended</string>
        </test>
        <edit name="family" mode="assign_replace">
          <string>Iosevka Custom Extended</string>
        </edit>
        <edit name="family" mode="append_last">
          <string>monospace</string>
        </edit>
      </match>

      <match target="pattern">
        <test qual="any" name="family">
            <string>monospace</string>
        </test>
        <edit name="family" mode="prepend_first">
          <string>Iosevka Custom Extended</string>
        </edit>
        <edit name="family" mode="prepend_first">
          <string>Noto Color Emoji</string>
        </edit>
      </match>

      <alias binding="strong">
        <family>emoji</family>
        <default><family>Noto Color Emoji</family></default>
      </alias>

      <alias binding="strong">
        <family>Apple Color Emoji</family>
        <prefer><family>Noto Color Emoji</family></prefer>
        <default><family>sans-serif</family></default>
      </alias>
      <alias binding="strong">
        <family>Segoe UI Emoji</family>
        <prefer><family>Noto Color Emoji</family></prefer>
        <default><family>sans-serif</family></default>
      </alias>
      <alias binding="strong">
        <family>Twitter Color Emoji</family>
        <prefer><family>Noto Color Emoji</family></prefer>
        <default><family>sans-serif</family></default>
    </alias>
    </fontconfig>
  '';
}
