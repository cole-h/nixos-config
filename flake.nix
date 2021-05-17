{
  # TODO: https://www.reddit.com/r/NixOS/comments/jd3bsd/adguard_home_in_container/g95etuf/
  # https://github.com/bqv/nixrc, https://github.com/colemickens/nixcfg
  description = "cole-h's NixOS configuration";

  inputs = {
    # Flakes
    # nixpkgs.url = "git+file:///home/vin/workspace/vcs/nixpkgs/master";
    # nixpkgs.url = "git+file:///home/vin/workspace/vcs/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/2f47650c2f28d87f86ab807b8a339c684d91ec56";
    # nixpkgs.url = "github:nixos/nixpkgs/master";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";

    agenix-rs = { url = "github:cole-h/agenix-rs"; };
    agenix = { url = "github:cole-h/agenix/symlink"; };
    # agenix = { url = "git+file:///home/vin/workspace/vcs/agenix"; };
    emacs = { url = "github:nix-community/emacs-overlay"; };
    home = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    # TODO: actually set up impermanence
    impermanence = { url = "github:nix-community/impermanence"; };
    mail = { url = "gitlab:simple-nixos-mailserver/nixos-mailserver"; inputs.nixpkgs.follows = "nixpkgs"; };
    # neovim = { url = "github:neovim/neovim?dir=contrib"; };
    nix = { url = "github:nixos/nix"; };
    # nix = { url = "github:nixos/nix/progress-bar"; };
    passrs = { url = "github:cole-h/passrs"; };
    # pijul = { url = "/home/vin/workspace/pijul/pijul"; };
    wayland = { url = "github:colemickens/nixpkgs-wayland"; };

    # Not flakes
    # baduk = { url = "github:dustinlacewell/baduk.nix"; flake = false; };
    # doom = { url = "github:hlissner/doom-emacs"; flake = false; };
    # mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
    aarch-images = { url = "github:Mic92/nixos-aarch64-images"; flake = false; };
  };

  outputs = inputs:
    let
      channels = {
        pkgs = inputs.nixpkgs;
      };

      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);

      config = {
        allowAliase = false;
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      pkgsFor = pkgs: system:
        import pkgs {
          inherit system config;
          overlays = [
            inputs.emacs.overlay
            (import ./overlay.nix {
              doom = null;
              # inherit (inputs) doom;
            })
            (final: prev: {
              passrs = inputs.passrs.defaultPackage.${system};
              # neovim-unwrapped = inputs.neovim.defaultPackage.${system};
              agenix = inputs.agenix-rs.defaultPackage.${system};
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
        , extraModules ? [ ]
        }:
        let
          inherit (pkgs) lib;
          inherit (inputs.agenix.nixosModules) age;
          inherit (inputs.impermanence.nixosModules) impermanence;

          nix = { ... }: {
            nix = {
              package = lib.mkForce inputs.nix.defaultPackage.${system};

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
        channels.pkgs.lib.nixosSystem {
          inherit system modules specialArgs pkgs;
        };
    in
    {
      # for use with update.sh script
      inputs = builtins.removeAttrs inputs [ "self" ];

      nixosConfigurations = {
        scadrial =
          let
            system = "x86_64-linux";
            pkgs = pkgsFor channels.pkgs system;
          in
          mkSystem {
            inherit system pkgs;
            hostname = "scadrial";
            extraModules =
              let
                inherit (pkgs) lib;
                inherit (lib) mkOption;
                inherit (lib.types) attrsOf submoduleWith;
                inherit (inputs.home.nixosModules) home-manager;

                home = { config, ... }: {
                  config.home-manager = {
                    users = import ./users;
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    verbose = true;

                    extraSpecialArgs = {
                      inherit inputs;
                      super = config;

                      my = import ./my.nix {
                        inherit lib;
                      };
                    };
                  };
                };
              in
              [
                home-manager
                home
              ];
          };

        bootstrap =
          let
            system = "x86_64-linux";
            pkgs = pkgsFor channels.pkgs system;
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

        scar =
          let
            system = "aarch64-linux";
            pkgs = pkgsFor channels.pkgs system;
          in
          mkSystem {
            inherit system pkgs;
            hostname = "scar"; # https://coppermind.net/wiki/Scar
          };

        yolen =
          let
            system = "x86_64-linux";
            pkgs = pkgsFor channels.pkgs system;
          in
          mkSystem {
            inherit system pkgs;
            hostname = "yolen";
            extraModules = [
              inputs.mail.nixosModules.mailserver
            ];
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
                system = "x86_64-linux";
                iso = import "${channels.pkgs}/nixos" {
                  configuration = ./iso.nix;
                  inherit system;
                };
              in
              iso.config.system.build.isoImage;

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

            do =
              let
                system = "x86_64-linux";
                do = import "${channels.pkgs}/nixos" {
                  configuration = ./do.nix;
                  inherit system;
                };
              in
              do.config.system.build.kexec_tarball;
          });

      legacyPackages = forAllSystems
        ({ pkgs, ... }: builtins.trace "Using <nixpkgs> compat wrapper..." pkgs);

      defaultPackage = forAllSystems
        ({ system, ... }:
          inputs.self.packages.${system}.scadrial);

      devShell = forAllSystems
        ({ system, pkgs, ... }:
          with pkgs;

          stdenv.mkDerivation {
            name = "shell";

            buildInputs =
              [
                git

                agenix
              ];
          });
    };
}
