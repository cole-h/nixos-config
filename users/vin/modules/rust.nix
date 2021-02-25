{ pkgs, lib, ... }:
let
  stableChannel = false;
  betaChannel = false;
  nightlyChannel = false;

  toolchains = with pkgs.latest.rustChannels;
    lib.optional stableChannel stable.rust
    ++ lib.optional betaChannel beta.rust
    ++ lib.optional nightlyChannel nightly.rust;

  rustpkgs = with pkgs.rust.packages.stable; [
    # cargo
    # clippy
    # rustc
    # rustfmt
  ];

in
{
  home = {
    packages = with pkgs; [
      rustup
      cargo-edit

      rust-analyzer
    ] ++ toolchains ++ rustpkgs;
  };
}
