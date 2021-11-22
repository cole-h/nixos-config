{ pkgsFor
, mkSystem
, inputs
}:
{
  scadrial =
    let
      system = "x86_64-linux";
      pkgs = pkgsFor inputs.nixpkgs system;
    in
    mkSystem {
      inherit system pkgs;
      hostname = "scadrial";
      extraModules =
        let
          inherit (pkgs) lib;
          inherit (inputs.home.nixosModules) home-manager;

          home = { config, ... }: {
            config.home-manager = {
              users = import ../users;
              useGlobalPkgs = true;
              useUserPackages = true;
              verbose = true;

              extraSpecialArgs = {
                inherit inputs;
                super = config;

                my = import ../my.nix {
                  inherit lib;
                };
              };
            };
          };

          nix = { lib, ... }: {
            nix.package = lib.mkForce inputs.nix.defaultPackage.${system};
          };
        in
        [
          home-manager
          home
          nix
        ];
    };

  scar =
    let
      system = "aarch64-linux";
      pkgs = pkgsFor inputs.nixpkgs system;
    in
    mkSystem {
      inherit system pkgs;
      hostname = "scar"; # https://coppermind.net/wiki/Scar
    };

  yolen =
    let
      system = "x86_64-linux";
      pkgs = pkgsFor inputs.nixpkgs system;
    in
    mkSystem {
      inherit system pkgs;
      hostname = "yolen";
      extraModules = [
        inputs.mail.nixosModules.mailserver
      ];
    };
}
