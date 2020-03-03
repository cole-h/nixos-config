final: super:
with super;

{
  # fonts
  san-francisco = callPackage ../drvs/san-francisco.nix { };
  sarasa-gothic = callPackage ../drvs/sarasa-gothic.nix { };

  # misc
  doom-emacs = callPackage ../drvs/doom-emacs.nix { };
}
