{
  # TODO: https://github.com/Infinisil/system/commit/054d68f0660a608999fccf2f63e3f33dc7c6e0e9
  # https://github.com/bqv/nixrc, https://github.com/colemickens/nixcfg
  description = "cole-h's NixOS configuration";

  inputs = {
    # Flakes
    # large.url = "git+file:///home/vin/workspace/vcs/nixpkgs/master";
    large.url = "github:nixos/nixpkgs/nixos-unstable";
    # master.url = "github:nixos/nixpkgs/master";
    small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # stable.url = "github:nixos/nixpkgs/nixos-20.09";

    nix = { url = "github:nixos/nix"; inputs.nixpkgs.follows = "small"; };
    home = { url = "github:rycee/home-manager"; inputs.nixpkgs.follows = "small"; };
    naersk = { url = "github:nmattia/naersk"; inputs.nixpkgs.follows = "small"; };
    passrs = { url = "github:cole-h/passrs"; };
    wayland = { url = "github:colemickens/nixpkgs-wayland"; };

    # Not flakes
    secrets = { url = "git+ssh://git@github.com/cole-h/nix-secrets.git"; flake = false; };
    # secrets = { url = "/home/vin/.config/nixpkgs/secrets"; flake = false; };
    alacritty = { url = "github:alacritty/alacritty"; flake = false; };
    # baduk = { url = "github:dustinlacewell/baduk.nix"; flake = false; };
    doom = { url = "github:hlissner/doom-emacs"; flake = false; };
    # mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
    nixus = { url = "github:infinisil/nixus"; flake = false; };
  };

  outputs = inputs:
    let
      channels = {
        pkgs = inputs.large;
        # modules = inputs.small;
        # lib = inputs.master;
      };
      # inherit (channels.lib) lib;

      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);

      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      pkgsFor = pkgs: system:
        import pkgs {
          inherit system config;
          overlays = [
            (import ./overlay.nix {
              inherit (inputs) doom naersk;

              passrs = inputs.passrs.defaultPackage.${system};
              alacrittySrc = inputs.alacritty;
            })
          ];
        };

      allSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: genAttrs allSystems
        (system: f {
          inherit system;
          pkgs = pkgsFor channels.pkgs system;
        });

      forOneSystem = system: f: f {
        inherit system;
        pkgs = pkgsFor channels.pkgs system;
      };

      mkSystem = system: pkgs: hostname:
        let
          inherit (pkgs.lib) mkOption;
          inherit (pkgs.lib.types) attrsOf submoduleWith;
          inherit (inputs.home.nixosModules) home-manager;

          home = { ... }: {
            # "submodule types have merging semantics" -- bqv
            options.home-manager.users = mkOption {
              type = attrsOf (submoduleWith {
                modules = [ ];
                # Makes specialArgs available to home-manager modules as well
                specialArgs = builtins.removeAttrs specialArgs [ "nixosConfig" ] // {
                  super = config; # access NixOS configuration from h-m
                };
              });
            };

            config.home-manager = {
              users = import ./users;
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;
            };
          };

          nix = { ... }: {
            nix = {
              package = inputs.nix.defaultPackage.${system}.overrideAttrs ({ patches ? [ ], ... }: {
                patches = patches ++ [
                  ./log-format-option.patch
                ];
              });

              extraOptions = ''
                log-format = bar-with-logs
              '';

              nixPath = [
                "pkgs=${inputs.self}/compat"
                "nixos-config=${inputs.self}/compat/nixos"
              ];
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

          modules = [
            home-manager
            home
            (./hosts + "/${hostname}/configuration.nix")
            nix
            misc
          ];

          specialArgs = {
            inherit inputs system;

            my = import ./my.nix {
              inherit (pkgs) lib;
              inherit (inputs) secrets;
            };
          };
        in
        channels.pkgs.lib.nixosSystem
          {
            inherit system modules specialArgs pkgs;
          } // { inherit modules; }; # let Nixus have access to this stuff

      nixus = sys: import inputs.nixus { deploySystem = sys; };
    in
    {
      inherit inputs;

      nixosConfigurations = {
        scadrial =
          let
            system = "x86_64-linux";
            pkgs = pkgsFor channels.pkgs system;
          in
          mkSystem system pkgs "scadrial";
      };

      packages = forAllSystems ({ system, ... }: {
        iso =
          let
            iso = import "${channels.pkgs}/nixos" {
              configuration = ./iso.nix;
              inherit system;
            };
          in
          iso.config.system.build.isoImage;
      });

      legacyPackages = forAllSystems ({ pkgs, ... }: pkgs);

      defaultPackage = {
        x86_64-linux = forOneSystem "x86_64-linux" ({ system, pkgs, ... }:
          nixus system ({ ... }: {
            defaults = { name, ... }:
              let
                nixos = inputs.self.nixosConfigurations.${name};
              in
              {
                nixpkgs = pkgs.path;

                configuration = {
                  imports = nixos.modules;
                };
              };

            nodes = {
              scadrial = { ... }: {
                host = "root@localhost";
                privilegeEscalationCommand = [ "exec" ];
              };
            };
          }));
        };

      apps = forAllSystems ({ system, ... }: {
        nixus = {
          type = "app";
          program = inputs.self.defaultPackage.${system}.outPath;
        };
      });

      defaultApp = forAllSystems ({ system, ... }: inputs.self.apps.${system}.nixus);

      devShell = forAllSystems ({ system, pkgs, ... }:
        with pkgs;

        stdenv.mkDerivation {
          name = "shell";

          buildInputs =
            [
              git
              git-crypt
            ];
        });
    };
}
