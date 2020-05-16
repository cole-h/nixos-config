{ config, lib, pkgs, ... }:
let
  stableChannel = true;
  betaChannel = false;
  nightlyChannel = false;
  toolchains = with pkgs.latest.rustChannels;
    lib.optional stableChannel stable.rust
    ++ lib.optional betaChannel beta.rust
    ++ lib.optional nightlyChannel nightly.rust;
in
{
  home = {
    packages = with pkgs; [
      cargo-about
      cargo-asm
      cargo-audit
      cargo-bloat
      cargo-crev
      cargo-edit
      cargo-expand
      cargo-flamegraph
      cargo-geiger
      cargo-license
      cargo-tree
      flamegraph
      rust-analyzer
    ] ++ toolchains;

    xdg.configFile = {
      ".cargo/credentials".source = config.lib.file.mkOutOfStoreSymlink ../../secrets/cargo-credentials;
    };
  };
}
