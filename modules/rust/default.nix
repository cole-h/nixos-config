{ pkgs, lib, ... }:

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
      hexyl
      hyperfine
      mdbook
      rust-analyzer
    ];

    # TODO: find a way to .source without adding to store or relying on NIX_PATH
    # home.file.".cargo/credentials".source = ./cargo-credentials;
    activation = with lib; {
      cargoCredentials = hm.dag.entryAfter [ "linkGeneration" ] ''
        $DRY_RUN_CMD unlink \
          ${config.home.homeDirectory}/.cargo/credentials 2>/dev/null || true
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
           ${toString <vin/secrets/cargo-credentials>} \
           ${config.home.homeDirectory}/.cargo/credentials
      '';
    };
  };
}
