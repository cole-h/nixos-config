{ inputs
}:
let
  inherit (inputs.self.lib)
    pkgsFor
    mkSystem
    ;
in
{
  scadrial =
    let
      system = "x86_64-linux";
    in
    {
      inherit system;

      extraModules =
        let
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
                  inherit (inputs.nixpkgs) lib;
                };
              };
            };
          };

          nix = { lib, ... }: {
            nix.package = lib.mkForce inputs.nix.defaultPackage.${system};
          };
        in
        [
          inputs.home.nixosModules.home-manager

          home
          nix
        ];
    };

  # https://coppermind.net/wiki/Scar
  scar = {
    system = "aarch64-linux";
  };

  yolen = {
    system = "x86_64-linux";
    extraModules = [
      inputs.mail.nixosModules.mailserver
    ];
  };
}
