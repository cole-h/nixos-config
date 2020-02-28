final: super:
with super;

{
  # fonts
  san-francisco = callPackage ../pkgs/san-francisco.nix { };
  sarasa-gothic = callPackage ../pkgs/sarasa-gothic.nix { };

  # misc
  doom-emacs = callPackage ../pkgs/doom-emacs.nix { };
}
