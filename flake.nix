{
  # TODO: https://www.reddit.com/r/NixOS/comments/jd3bsd/adguard_home_in_container/g95etuf/
  # https://github.com/bqv/nixrc, https://github.com/colemickens/nixcfg
  description = "cole-h's NixOS configuration";

  inputs = {
    # Flakes
    # large.url = "git+file:///home/vin/workspace/vcs/nixpkgs/master";
    large.url = "github:nixos/nixpkgs/nixos-unstable";
    # master.url = "github:nixos/nixpkgs/master";
    # small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # stable.url = "github:nixos/nixpkgs/nixos-20.09";

    nix = { url = "github:nixos/nix"; };
    # nix = { url = "github:nixos/nix/progress-bar"; };
    home = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "large"; };
    passrs = { url = "github:cole-h/passrs"; };
    wayland = { url = "github:colemickens/nixpkgs-wayland"; };
    emacs = { url = "github:nix-community/emacs-overlay"; };
    alacritty = { url = "github:cole-h/flake-alacritty"; };
    # pijul = { url = "/home/vin/workspace/pijul/pijul"; };
    neovim = { url = "github:neovim/neovim?dir=contrib"; };

    # Not flakes
    secrets = { url = "git+ssh://git@github.com/cole-h/nix-secrets.git"; flake = false; };
    # secrets = { url = "/home/vin/.config/nixpkgs/secrets"; flake = false; };
    # baduk = { url = "github:dustinlacewell/baduk.nix"; flake = false; };
    doom = { url = "github:hlissner/doom-emacs"; flake = false; };
    # mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
    aarch-images = { url = "github:Mic92/nixos-aarch64-images"; flake = false; };
  };

  outputs = inputs:
    let
      channels = {
        pkgs = inputs.large;
      };

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
            inputs.emacs.overlay
            (import ./overlay.nix {
              inherit (inputs) doom;
            })
            (final: prev: {
              passrs = inputs.passrs.defaultPackage.${system};
              alacritty = inputs.alacritty.defaultPackage.${system};
              neovim-unwrapped = inputs.neovim.defaultPackage.${system};
              # pijul = inputs.pijul.defaultPackage.${system};
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

      mkSystem =
        { system
        , pkgs
        , hostname
        , includeHome ? true
        }:
        let
          inherit (pkgs) lib;
          inherit (lib) mkOption;
          inherit (lib.types) attrsOf submoduleWith;
          inherit (inputs.home.nixosModules) home-manager;

          home = { ... }: {
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

            config.home-manager = {
              users = import ./users;
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;
            };
          };

          nix = { ... }: {
            nix = {
              package = lib.mkForce (inputs.nix.defaultPackage.${system}.overrideAttrs ({ patches ? [ ], ... }: {
                patches = patches ++ [
                  ./log-format-option.patch
                ];
              }));

              # print-build-logs = true
              extraOptions = ''
                log-format = bar-with-logs
                flake-registry = /etc/nix/registry.json
              '';

              nixPath = [
                "pkgs=${inputs.self}/compat"
                "nixos-config=${inputs.self}/compat/nixos"
              ];

              registry = {
                self.flake = inputs.self;

                nixpkgs = {
                  from = { id = "nixpkgs"; type = "indirect"; };
                  flake = channels.pkgs;
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

          modules = lib.optionals includeHome [
            # This stuff is too big for my flash drive
            home-manager
            home
          ] ++ [
            { networking.hostName = hostname; }
            (./hosts + "/${hostname}/configuration.nix")
            nix
            misc
          ];

          specialArgs = {
            inherit inputs system;

            my = import ./my.nix {
              inherit lib;
              inherit (inputs) secrets;
            };
          };
        in
        channels.pkgs.lib.nixosSystem {
          inherit system modules specialArgs pkgs;
        };
    in
    {
      inherit inputs;

      nixosConfigurations = {
        scadrial =
          let
            system = "x86_64-linux";
            pkgs = pkgsFor channels.pkgs system;
          in
          mkSystem {
            inherit system pkgs;
            hostname = "scadrial";
          };

        bootstrap =
          let
            system = "x86_64-linux";
            pkgs = pkgsFor channels.pkgs system;
          in
          mkSystem {
            inherit system pkgs;
            hostname = "scadrial";
            includeHome = false;
          };

        scar =
          let
            system = "aarch64-linux";
            pkgs = pkgsFor channels.pkgs system;
          in
          mkSystem {
            inherit system pkgs;
            hostname = "scar"; # https://coppermind.net/wiki/Scar
            includeHome = false;
          };
      };

      packages = forAllSystems
        ({ system, ... }:
          (builtins.listToAttrs (map
            (k: nameValuePair k inputs.self.nixosConfigurations.${k}.config.system.build.toplevel)
            (builtins.attrNames inputs.self.nixosConfigurations)
          )) // {
            iso =
              let
                iso = import "${channels.pkgs}/nixos" {
                  configuration = ./iso.nix;
                  inherit system;
                };
              in
              iso.config.system.build.isoImage;
          }) //
      {
        sd =
          let
            system = "aarch64-linux";
            pkgs = pkgsFor channels.pkgs system;
            buildImage = pkgs.callPackage "${inputs.aarch-images}/pkgs/build-image" { };

            image = (import "${channels.pkgs}/nixos" {
              configuration = ./sd.nix;
              inherit system;
            }).config.system.build.sdImage;
          in
          pkgs.callPackage "${inputs.aarch-images}/images/rockchip.nix" {
            inherit buildImage;
            uboot = pkgs.ubootRock64;
            aarch64Image = pkgs.stdenv.mkDerivation {
              name = "sd";
              src = image;

              phases = [ "installPhase" ];
              noAuditTmpdir = true;
              preferLocalBuild = true;

              installPhase = "ln -s $src/sd-image/*.img $out";
            };
          };
      };

      legacyPackages = forAllSystems ({ pkgs, ... }: pkgs);

      defaultPackage = forAllSystems ({ system, ... }:
        inputs.self.packages.${system}.scadrial);

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
