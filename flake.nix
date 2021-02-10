{
  # TODO: https://www.reddit.com/r/NixOS/comments/jd3bsd/adguard_home_in_container/g95etuf/
  # https://github.com/bqv/nixrc, https://github.com/colemickens/nixcfg
  description = "cole-h's NixOS configuration";

  inputs = {
    # Flakes
    # nixpkgs.url = "git+file:///home/vin/workspace/vcs/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/2f47650c2f28d87f86ab807b8a339c684d91ec56";
    # nixpkgs.url = "github:nixos/nixpkgs/master";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";

    nix = { url = "github:nixos/nix"; };
    # nix = { url = "github:nixos/nix/progress-bar"; };
    home = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    passrs = { url = "github:cole-h/passrs"; };
    wayland = { url = "github:colemickens/nixpkgs-wayland"; };
    emacs = { url = "github:nix-community/emacs-overlay"; };
    alacritty = { url = "github:cole-h/flake-alacritty"; };
    # pijul = { url = "/home/vin/workspace/pijul/pijul"; };
    neovim = { url = "github:neovim/neovim?dir=contrib"; };
    # TODO: switch all / most secrets to sops
    sops = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    agenix = { url = "git+file:///home/vin/workspace/vcs/agenix"; };
    mail = { url = "gitlab:simple-nixos-mailserver/nixos-mailserver"; inputs.nixpkgs.follows = "nixpkgs"; };

    # Not flakes
    # baduk = { url = "github:dustinlacewell/baduk.nix"; flake = false; };
    doom = { url = "github:hlissner/doom-emacs"; flake = false; };
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
        , extraModules ? [ ]
        }:
        let
          inherit (pkgs) lib;
          inherit (inputs.sops.nixosModules) sops;
          inherit (inputs.agenix.nixosModules) age;

          nix = { ... }: {
            nix = {
              package = lib.mkForce inputs.nix.defaultPackage.${system};
              checkConfig = false; # --no-net was renamed to --offline

              # print-build-logs = true
              # log-format = bar-with-logs
              extraOptions = ''
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

            # system.activationScripts.setup-secrets = pkgs.lib.mkForce "";
            # age.defaultPubKey = "RWQflwR3rpBIGhY68arhyDoAXFKksT0uI/cTdafx84otEgXyTOaHgUbI";
            # age.secrets.test = {
            #   file = ./test.age;
            #   signature.file = ./test.age.minisig;
            # };
          };

          modules = extraModules ++ [
            { networking.hostName = hostname; }
            (./hosts + "/${hostname}/configuration.nix")
            nix
            misc
            sops
            age
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
                inherit (inputs.home.nixosModules) home-manager;

                home = { ... }: {
                  config.home-manager = {
                    users = import ./users;
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    verbose = true;
                  };
                };
              in
              [
                home-manager
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
        ({ pkgs, ... }: pkgs);

      defaultPackage = forAllSystems
        ({ system, ... }:
          inputs.self.packages.${system}.scadrial);

      devShell = forAllSystems
        ({ system, pkgs, ... }:
          with pkgs;

          stdenv.mkDerivation {
            name = "shell";

            sopsPGPKeyDirs = [
              "./keys/hosts"
              "./keys/users"
            ];

            nativeBuildInputs = [
              inputs.sops.packages.${system}.sops-pgp-hook
            ];

            buildInputs =
              [
                git
                git-crypt
                sops

                inputs.sops.packages.${system}.ssh-to-pgp
              ];
          });
    };
}
