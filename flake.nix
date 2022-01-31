{
  description = "cole-h's NixOS configuration";

  inputs = {
    # Flakes
    # nixpkgs.url = "git+file:///home/vin/workspace/vcs/nixpkgs/master";
    # nixpkgs.url = "git+file:///home/vin/workspace/vcs/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/2f47650c2f28d87f86ab807b8a339c684d91ec56";
    # nixpkgs.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
    fixpkgs.url = "github:nixos/nixpkgs/fd8f6de4b8415fe4dcea3a9cbb9ab9eebd37b53a";

    agenix-cli = { url = "github:cole-h/agenix-cli"; inputs.nixpkgs.follows = "nixpkgs"; };
    agenix = { url = "github:ryantm/agenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    home = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    mail = { url = "gitlab:simple-nixos-mailserver/nixos-mailserver"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix = { url = "github:nixos/nix"; inputs.nixpkgs.follows = "nixpkgs"; };

    # Not flakes
    aarch-images = { url = "github:Mic92/nixos-aarch64-images"; flake = false; };
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
      # for use with update.sh script
      inputs = builtins.removeAttrs inputs [ "self" ];

      lib = import ./nix/lib.nix { inherit inputs; };

      nixosConfigurations = {
        bootstrap =
          let
            system = "x86_64-linux";
            pkgs = pkgsFor {
              inherit inputs system;
              inherit (inputs) nixpkgs;
            };
          in
          mkSystem {
            inherit system pkgs;
            hostname = "scadrial";
            extraModules = [
              {
                # age.sshKeyPaths = [ "/tmp/host/ed25519" ];
              }
            ];
          };
      } // builtins.mapAttrs
        (flip ({ system, extraModules ? [ ] }: hostname:
          mkSystem {
            pkgs = pkgsFor {
              inherit inputs system;
              inherit (inputs) nixpkgs;
            };

            inherit
              hostname
              system
              extraModules
              ;
          }))
        (import ./hosts { inherit inputs; });

      packages = forAllSystems
        ({ ... }:
          (builtins.mapAttrs
            (hostname: conf: conf.config.system.build.toplevel)
            inputs.self.nixosConfigurations
          ) // {
            iso = import ./nix/iso.nix { inherit inputs; };
            sd = import ./nix/sd.nix { inherit inputs; };
            do = import ./nix/do.nix { inherit inputs; };
          });

      legacyPackages = forAllSystems
        ({ pkgs, ... }: builtins.trace "Using <nixpkgs> compat wrapper..." (pkgs.recurseIntoAttrs pkgs));

      defaultPackage = forAllSystems
        ({ system, ... }: inputs.self.packages.${system}.scadrial);
    };
}
