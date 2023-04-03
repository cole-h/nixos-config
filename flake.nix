{
  description = "cole-h's NixOS configuration";

  inputs = {
    # Flakes
    # nixpkgs.url = "git+file:///home/vin/workspace/vcs/nixpkgs/master";
    # nixpkgs.url = "git+file:///home/vin/workspace/vcs/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/2f47650c2f28d87f86ab807b8a339c684d91ec56";
    # nixpkgs.url = "github:nixos/nixpkgs/master";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";

    agenix-cli = { url = "github:cole-h/agenix-cli"; inputs.nixpkgs.follows = "nixpkgs"; };
    agenix = { url = "github:ryantm/agenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    home = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    # nix = { url = "github:nixos/nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix = { url = "github:edolstra/nix/lazy-trees"; inputs.nixpkgs.follows = "nixpkgs"; };
    naersk= { url = "github:nix-community/naersk"; inputs.nixpkgs.follows = "nixpkgs"; };

    # Not flakes
    wezterm = { url = "git+https://github.com/wez/wezterm.git?submodules=1"; flake = false; };
  };

  outputs = inputs:
    let
      inherit (inputs.self.lib)
        forAllSystems
        nameValuePair
        pkgsFor
        mkSystem
        ;

      inherit (inputs.nixpkgs.lib)
        flip
        ;
    in
    {
      inherit inputs;

      lib = import ./nix/lib.nix { inherit inputs; };

      nixosConfigurations =
        builtins.mapAttrs
          (flip
            ({ system, modules ? [ ] }: hostname:
              mkSystem {
                inherit
                  system
                  modules
                  ;

                pkgs = pkgsFor {
                  inherit inputs system;
                  inherit (inputs) nixpkgs;
                };
              }))
          (import ./hosts { inherit inputs; });

      packages = forAllSystems
        ({ system, ... }:
          (builtins.mapAttrs
            (hostname: conf: conf.config.system.build.toplevel)
            inputs.self.nixosConfigurations
          ) // {
            default = inputs.self.packages.${system}.scadrial;
            iso = import ./nix/iso.nix { inherit inputs system; };
          });

      legacyPackages = forAllSystems
        ({ pkgs, ... }: builtins.trace "Using <nixpkgs> compat wrapper..." (pkgs.recurseIntoAttrs pkgs));
    };
}
