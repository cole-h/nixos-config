{
  # TODO: https://github.com/bqv/nixrc, https://github.com/colemickens/nixcfg
  description = "cole-h's NixOS configuration";

  inputs = {
    # Flakes
    # large.url = "github:nixos/nixpkgs/nixos-unstable";
    # master.url = "github:nixos/nixpkgs/master";
    small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # stable.url = "github:nixos/nixpkgs/nixos-20.09";

    home = { url = "github:rycee/home-manager"; inputs.nixpkgs.follows = "small"; };
    naersk = { url = "github:nmattia/naersk"; inputs.nixpkgs.follows = "small"; };
    passrs = { url = "github:cole-h/passrs"; inputs.nixpkgs.follows = "small"; };
    # utils = { url = "github:numtide/flake-utils"; inputs.nixpkgs.follows = "large"; };

    # Not flakes
    # TODO: flake-compat does not support file-type inputs
    secrets = { url = "/home/vin/.config/nixpkgs/secrets"; flake = false; };
    alacritty = { url = "github:alacritty/alacritty"; flake = false; };
    # baduk = { url = "github:dustinlacewell/baduk.nix"; flake = false; };
    doom = { url = "github:hlissner/doom-emacs"; flake = false; };
    # mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
    nixus = { url = "github:infinisil/nixus"; flake = false; };
    pgtk = { url = "github:masm11/emacs"; flake = false; };
  };

  outputs = inputs:
    let
      channels = {
        pkgs = inputs.small;
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
              inherit (inputs) doom naersk pgtk;

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

          home = { config, ... }: {
            # "submodule types have merging semantics" -- bqv
            options.home-manager.users = mkOption {
              type = attrsOf (submoduleWith {
                modules = [ ];
                # Makes specialArgs available to home-manager modules as well
                specialArgs = specialArgs // {
                  super = config; # access NixOS configuration from h-m
                };
              });
            };
          };

          modules = [
            (./hosts + "/${hostname}/configuration.nix")
            inputs.home.nixosModules.home-manager
            home
          ];

          specialArgs = {
            inherit inputs;

            my = import ./my.nix {
              inherit (pkgs) lib;
              inherit (inputs) secrets;
            };
          };
        in
        channels.pkgs.lib.nixosSystem
          {
            inherit system modules specialArgs;
          } // { inherit specialArgs modules; }; # let Nixus have access to this stuff
    in
    {
      nixosConfigurations = {
        scadrial =
          let
            system = "x86_64-linux";
            pkgs = pkgsFor channels.pkgs system;
          in
          mkSystem system pkgs "scadrial";
      };

      legacyPackages = forAllSystems ({ pkgs, ... }: pkgs);

      # TODO: nixus = system: f: ....
      defaultPackage = {
        x86_64-linux = forOneSystem "x86_64-linux" ({ system, pkgs, ... }:
          import inputs.nixus { deploySystem = system; } ({ ... }: {
            defaults = { name, ... }:
              let
                nixos = inputs.self.nixosConfigurations.${name};
              in
              {
                nixpkgs = pkgs.path;

                configuration = {
                  _module.args = nixos.specialArgs;
                  imports = nixos.modules;
                  nixpkgs = { inherit pkgs; };

                  system.configurationRevision = inputs.self.rev or "dirty";
                  system.nixos.versionSuffix =
                    let
                      inherit (inputs) self;
                      date = builtins.substring 0 8 (self.lastModifiedDate or self.lastModified);
                      rev = self.shortRev or "dirty";
                    in
                    ".${date}.${rev}-cosmere";
                };
              };

            nodes = {
              scadrial = { ... }: {
                host = "root@localhost";
                privilegeEscalationCommand = [ "exec" ];

                configuration = {
                  nix.nixPath = [
                    "pkgs=${inputs.self}/compat"
                    "nixos-config=${inputs.self}/compat/nixos"
                  ];
                };
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
    };

}
