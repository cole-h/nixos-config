{
  # TODO: https://github.com/bqv/nixrc, https://github.com/colemickens/nixcfg
  description = "cole-h's NixOS configuration";

  inputs = {
    # Flakes
    master.url = "github:nixos/nixpkgs/master";
    stable.url = "github:nixos/nixpkgs/nixos-20.03";
    small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    large.url = "github:nixos/nixpkgs/nixos-unstable";
    naersk = { url = "github:nmattia/naersk"; inputs.nixpkgs.follows = "large"; };
    home = { url = "github:rycee/home-manager"; inputs.nixpkgs.follows = "large"; };
    nixops = { url = "github:nixos/nixops"; inputs.nixpkgs.follows = "large"; };
    # utils = { url = "github:numtide/flake-utils"; inputs.nixpkgs.follows = "large"; };

    # Not flakes
    nixus = { url = "github:infinisil/nixus"; flake = false; };
    mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
    # baduk = { url = "github:dustinlacewell/baduk.nix"; flake = false; };
    doom = { url = "github:hlissner/doom-emacs"; flake = false; };
    pgtk = { url = "github:masm11/emacs"; flake = false; };
    passrs = { url = "github:cole-h/passrs"; flake = false; };
    alacritty = { url = "github:alacritty/alacritty"; flake = false; };
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
            (import inputs.mozilla) # FIXME: impure
            (import ./overlays {
              inherit (inputs) doom naersk pgtk;

              passrsSrc = inputs.passrs;
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
            my = import ./my.nix pkgs.lib;

            inherit inputs;
          };
        in
        pkgs.lib.nixosSystem
          {
            inherit system modules specialArgs;
          } // { inherit specialArgs modules; }; # let Nixus have access to this stuff
    in
    {
      nixosConfigurations = {
        scadrial = mkSystem "x86_64-linux" channels.pkgs "scadrial";
      };

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
                };
              };

            nodes = {
              scadrial = { ... }: {
                # TODO: make deploy user with passwordless doas for cat, mkdir, rsync, and self
                host = "root@localhost";
                # TODO: maybe try exec cuz this is already running from root via ssh
                privilegeEscalationCommand = [ "doas" ]; # needs cat, mkdir, rsync, and self?

                configuration = {
                  nix.nixPath = [
                    "nixpkgs=${pkgs.path}"
                    "nixos-config=/etc/nixos/configuration.nix"
                    "/nix/var/nix/profiles/per-user/root/channels"
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
