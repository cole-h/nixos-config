final: super:

let
  doJailbreak = (import <nixpkgs/pkgs/development/haskell-modules/lib.nix> {
    inherit (super.pkgs) lib;
    inherit (super) pkgs;
  }).doJailbreak;
in {
  nixfmt =
    doJailbreak (super.nixfmt.overrideAttrs (_: { meta.broken = false; }));
}
