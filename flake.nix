{
  # TODO: https://www.reddit.com/r/NixOS/comments/jd3bsd/adguard_home_in_container/g95etuf/
  # https://github.com/bqv/nixrc, https://github.com/colemickens/nixcfg
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

    agenix-cli = { url = "github:cole-h/agenix-cli"; };
    agenix = { url = "github:ryantm/agenix"; };
    home = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    # TODO: actually set up impermanence
    impermanence = { url = "github:nix-community/impermanence"; };
    mail = { url = "gitlab:simple-nixos-mailserver/nixos-mailserver"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix = { url = "github:nixos/nix"; };
    wayland = { url = "github:nix-community/nixpkgs-wayland"; };

    # Not flakes
    aarch-images = { url = "github:Mic92/nixos-aarch64-images"; flake = false; };
  };

  outputs = inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);


      pkgsFor = pkgs: system:
        import pkgs {
          inherit system;

          config = {
            allowAliases = false;
            allowUnfree = true;
            android_sdk.accept_license = true;
          };

          overlays = [
            (import ./overlay.nix)
            (final: prev: {
              agenix = inputs.agenix-cli.defaultPackage.${system};
            })
          ];
        };

      allSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: genAttrs allSystems
        (system: f {
          inherit system;
          pkgs = pkgsFor inputs.nixpkgs system;
        });

      forOneSystem = system: f: f {
        inherit system;
        pkgs = pkgsFor inputs.nixpkgs system;
      };

      mkSystem =
        { system
        , pkgs
        , hostname
        , extraModules ? [ ]
        }:
        let
          inherit (pkgs) lib;
          inherit (inputs.agenix.nixosModules) age;
          inherit (inputs.impermanence.nixosModules) impermanence;

          nix = { ... }: {
            nix = {
              # print-build-logs = true
              # log-format = bar-with-logs
              extraOptions = ''
                flake-registry = /etc/nix/registry.json
              '';

              nixPath = [
                "nixpkgs=${inputs.self}/compat"
                "nixos-config=${inputs.self}/compat/nixos"
              ];

              registry = {
                self.flake = inputs.self;

                nixpkgs = {
                  from = { id = "nixpkgs"; type = "indirect"; };
                  flake = inputs.nixpkgs;
                };
              };
            };
          };

          misc = { ... }: {
            _module.args = specialArgs;
            nixpkgs.pkgs = pkgs;

            system.configurationRevision = inputs.self.rev or "dirty";
            system.nixos.versionSuffix =
              let
                inherit (inputs) self;
                inherit (pkgs) lib;
                date = builtins.substring 0 8 (self.lastModifiedDate or self.lastModified);
                rev = self.shortRev or "dirty";
              in
              lib.mkForce ".${date}.${rev}-cosmere";
          };

          modules = extraModules ++ [
            { networking.hostName = hostname; }
            (./hosts + "/${hostname}/configuration.nix")
            nix
            misc
            age
            impermanence
          ];

          specialArgs = {
            inherit inputs system;

            my = import ./my.nix {
              inherit lib;
            };
          };
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system modules specialArgs pkgs;
        };
    in
    {
      # for use with update.sh script
      inputs = builtins.removeAttrs inputs [ "self" ];

      nixosConfigurations = {
        bootstrap =
          let
            system = "x86_64-linux";
            pkgs = pkgsFor inputs.nixpkgs system;
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
      } // (import ./hosts { inherit pkgsFor mkSystem inputs; });

      packages = forAllSystems
        ({ system, ... }:
          (builtins.listToAttrs (map
            (k: nameValuePair k inputs.self.nixosConfigurations.${k}.config.system.build.toplevel)
            (builtins.attrNames inputs.self.nixosConfigurations)
          )) // {
            iso = import ./iso.nix { inherit inputs; };
            sd = import ./sd.nix { inherit pkgsFor inputs; };
            do = import ./do.nix { inherit inputs; };
          });

      legacyPackages = forAllSystems
        ({ pkgs, ... }: builtins.trace "Using <nixpkgs> compat wrapper..." (pkgs.recurseIntoAttrs pkgs));

      defaultPackage = forAllSystems
        ({ system, ... }: inputs.self.packages.${system}.scadrial);
    };
}
