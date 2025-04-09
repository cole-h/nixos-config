{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    ttf_bitstream_vera
    font-awesome_4
    nerd-fonts.symbols-only
    unifont

    noto-fonts-color-emoji # emoji font
    noto-fonts
    noto-fonts-cjk-sans
    ttf_bitstream_vera
    jetbrains-mono # code font
    kochi-substitute # JP font
    ipafont # JP font
    atkinson-hyperlegible-mono # code font
  ];
}
