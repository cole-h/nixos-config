{ config, lib, pkgs, ... }:
let
  betaChannel = false;
  nightlyChannel = false;

  toolchains = with pkgs.latest.rustChannels;
    [ stable.rust ]
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

      # FIXME: https://github.com/NixOS/nixpkgs/pull/77752
      # rust-analyzer
    ] ++ toolchains;

    # TODO: find a way to link without adding to store or relying on NIX_PATH
    activation = with lib; {
      cargoCredentials = hm.dag.entryAfter [ "linkGeneration" ] ''
        $DRY_RUN_CMD unlink \
          ${config.home.homeDirectory}/.cargo/credentials 2>/dev/null || true
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
           ${toString ../secrets/cargo-credentials} \
           ${config.home.homeDirectory}/.cargo/credentials
      '';
    };
  };
}
