final: super:
with super;

{
  # fonts
  san-francisco = callPackage ../drvs/san-francisco.nix { };
  sarasa-gothic = callPackage ../drvs/sarasa-gothic.nix { };
  ipaexfont = callPackage ../drvs/ipaexfont.nix { };

  # misc
  doom-emacs = callPackage ../drvs/doom-emacs.nix { };

  # single-line overrides
  mpv = mpv.override { vdpauSupport = false; };
  waybar = waybar.override { pulseSupport = true; };
  ripgrep = ripgrep.override { withPCRE2 = true; };
}
