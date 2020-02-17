{ pkgs ? import <nixpkgs> { }, ... }:
with pkgs;

{
  # fonts
  san-francisco = callPackage ./san-francisco.nix { };
  sarasa-gothic = callPackage ./sarasa-gothic.nix { };
  # cozette = callPackage ./cozette.nix { };

  # misc
  chatterino2 = libsForQt5.callPackage ./chatterino2.nix { };
}
