{ config, lib, pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fontconfig
    iosevka # code font
    sarasa-gothic # Iosevka, but East
    jetbrains-mono # code font
    inter # nice UI font
    ttf_bitstream_vera
    liberation_ttf
    source-han-sans-japanese
    san-francisco # Apple UI font
    # fira code
    # hack
    # input mono
    # office code pro
  ];

  # ~/.nix-profile/share/fonts/truetype
  # xdg.dataFile."fonts/truetype" = {
  #   recursive = true;
  #   source = pkgs + "/share/fonts/truetype";
  # };

  xdg.dataFile."fonts/iosevka" = {
    recursive = true;
    source = pkgs.iosevka + "/share/fonts/truetype";
  };

  xdg.dataFile."fonts/jetbrains-mono" = {
    recursive = true;
    source = pkgs.jetbrains-mono + "/share/fonts/truetype";
  };
}
