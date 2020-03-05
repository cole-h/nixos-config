self: super:
with super;

let
  composeExtensions2 = f: g: lib.composeExtensions f g;
  composeExtensions3 = f: g: h: composeExtensions2 f (composeExtensions2 g h);

  sources = import <vin/nix/sources.nix>;
  emacs = import sources.emacs-overlay;
  wayland = import sources.nixpkgs-wayland;
  mozilla = import sources.nixpkgs-mozilla;
in composeExtensions3 mozilla emacs wayland self super
