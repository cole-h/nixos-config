final: super:
with super;
let
  sources = import ../nix/sources.nix;
  naersk = callPackage sources.naersk { };
in
{
  # fonts
  # san-francisco = callPackage ../drvs/san-francisco.nix {};
  # sarasa-gothic = callPackage ../drvs/sarasa-gothic.nix {};

  # misc
  aerc = callPackage ../drvs/aerc.nix { };
  bemenu = callPackage ../drvs/bemenu.nix { };
  chatterino2 = libsForQt5.callPackage ../drvs/chatterino2.nix { };
  doom-emacs = callPackage ../drvs/doom-emacs.nix { };
  fish = callPackage ../drvs/fish.nix { };
  foliate = callPackage ../drvs/foliate.nix { };
  gsfonts = callPackage ../drvs/gsfonts.nix { };
  iosevka-custom = callPackage ../drvs/iosevka/iosevka-custom.nix { };

  alacritty = callPackage ../drvs/alacritty.nix {
    inherit (naersk) buildPackage;
  };

  zoxide = callPackage ../drvs/zoxide.nix {
    inherit (naersk) buildPackage;
  };

  # single-line overrides
  ripgrep = ripgrep.override { withPCRE2 = true; };
  rofi = rofi.override { plugins = [ rofi-emoji ]; };
}
