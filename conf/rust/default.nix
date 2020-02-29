{ pkgs, ... }:

{
  home.packages = with pkgs; [
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

  home.file.".cargo/credentials".source = ./cargo-credentials;
}
