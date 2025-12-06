{
  description = "cole-h's NixOS configuration";

  inputs = {
    # Flakes
    # nixpkgs.url = "git+file:///home/vin/workspace/vcs/nixpkgs/master";
    # nixpkgs.url = "git+file:///home/vin/workspace/vcs/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/5b09dc45f24cf32316283e62aec81ffee3c3e376";
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
      url = "github:DeterminateSystems/nix-src";
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
      url = "github:YaLTeR/niri";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
    deploy-rs = {
      # https://github.com/serokell/deploy-rs/pull/353
      url = "github:serokell/deploy-rs/8c9e56106ac5f1fbbd160c95f90ab5a28d386804";
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
        recurseIntoAttrs
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

      deploy.nodes = {
        scadrial = {
          hostname = "scadrial";

          fastConnection = true;
          # autoRollback = false;
          # magicRollback = false;
          remoteBuild = false;

          profiles.system = {
            sshUser = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.scadrial;
          };
        };

        cultivation = {
          hostname = "cultivation";

          fastConnection = true;
          # autoRollback = false;
          # magicRollback = false;
          remoteBuild = false;

          profiles.system = {
            sshUser = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.cultivation;
          };
        };
      };

      packages = {
        x86_64-linux.iso = import ./lib/iso.nix { system = "x86_64-linux"; inherit inputs; };
      };

      legacyPackages = forAllSystems
        ({ pkgs, ... }: builtins.trace "Using <nixpkgs> compat wrapper..." (recurseIntoAttrs pkgs));
    };
}
