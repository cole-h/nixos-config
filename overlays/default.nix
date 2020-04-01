final: super:
with super;

{
  # fonts
  san-francisco = callPackage ../drvs/san-francisco.nix {};
  sarasa-gothic = callPackage ../drvs/sarasa-gothic.nix {};

  # misc
  doom-emacs = callPackage ../drvs/doom-emacs.nix {};
  zoxide = callPackage ../drvs/zoxide.nix {};
  gsfonts = callPackage ../drvs/gsfonts.nix {};
  aerc = callPackage ../drvs/aerc.nix {};
  alacritty = callPackage ../drvs/alacritty.nix {};
  bemenu = (callPackage ../drvs/bemenu.nix {}).override { ncursesSupport = false; x11Support = false; };
  fish = callPackage ../drvs/fish/fish.nix {};

  # single-line overrides
  mpv = mpv.override { vdpauSupport = false; };
  ripgrep = ripgrep.override { withPCRE2 = true; };
  rofi = rofi.override { plugins = [ rofi-emoji ]; };
}
