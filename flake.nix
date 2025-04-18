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
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    agenix-cli = {
      url = "github:cole-h/agenix-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "darwin";
      inputs.home-manager.follows = "home";
    };
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix = {
      url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
      # url = "github:edolstra/nix/lazy-trees";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:YaLTeR/niri?ref=pull/1440/head";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "";
    };
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
    };
    flake-compat.url = "github:edolstra/flake-compat";

    # Not flakes
  };

  outputs = inputs:
    let
      inherit (inputs.self.lib)
        forAllSystems
        nameValuePair
        mkNixosSystem
        mkDarwinSystem
        ;

      inherit (inputs.nixpkgs.lib)
        flip
        ;
    in
    {
      inherit inputs;

      lib = import ./lib/lib.nix { inherit inputs; };

      nixosConfigurations =
        builtins.mapAttrs
          (flip
            ({ system, modules ? [ ] }: hostname:
              mkNixosSystem {
                inherit
                  system
                  modules
                  ;
              }))
          (import ./hosts/nixos { inherit inputs; });

      darwinConfigurations =
        builtins.mapAttrs
          (flip
            ({ system, modules ? [ ] }: hostname:
              mkDarwinSystem {
                inherit
                  system
                  modules
                  ;
              }))
          (import ./hosts/darwin { inherit inputs; });

      packages = {
        x86_64-linux.iso = import ./lib/iso.nix { system = "x86_64-linux"; inherit inputs; };
      };

      legacyPackages = forAllSystems
        ({ pkgs, ... }: builtins.trace "Using <nixpkgs> compat wrapper..." (pkgs.recurseIntoAttrs pkgs));
    };
}
