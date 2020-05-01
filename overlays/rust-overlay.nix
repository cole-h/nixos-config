let
  sources = import ../nix/sources.nix;
  nixpkgs-mozilla = sources.nixpkgs-mozilla;
  rust-overlay = import "${nixpkgs-mozilla}/rust-overlay.nix";
in
rust-overlay
