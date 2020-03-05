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
    ];

    activation = with lib; {
      cargoCredentials = hm.dag.entryAfter [ "linkGeneration" ] ''
        $DRY_RUN_CMD unlink ${config.home.homeDirectory}/.cargo/credentials || true
        $DRY_RUN_CMD ln -s $VERBOSE_ARG \
           ${toString <vin/secrets/cargo-credentials>} \
           ${config.home.homeDirectory}/.cargo/credentials
      '';
    };
  };

  # TODO: find a way to .source without adding to store
  # home.file.".cargo/credentials".source = ./cargo-credentials;
}
