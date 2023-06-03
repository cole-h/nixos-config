{ inputs
}:
let
  inherit (inputs.self.lib)
    specialArgs
    nixpkgsConfig
    nixpkgsOverlays
    ;

  inherit (inputs.nixpkgs.lib)
    flip
    ;

  machines = {
    # To bootstrap:
    # nix build ~/flake#darwinConfigurations.catacendre.system
    # ./result/sw/bin/darwin-rebuild switch --flake ~/flake
    catacendre =
      let
        system = "aarch64-darwin";
      in
      {
        inherit system;

        extraModules =
          let
            home = { config, ... }: {
              home-manager = {
                users = import ../../users/catacendre;
                useGlobalPkgs = true;
                useUserPackages = true;
                verbose = true;

                extraSpecialArgs = specialArgs // {
                  super = config;
                };
              };
            };

            nix = { lib, ... }: {
              # nix.package = lib.mkForce inputs.nix.packages.${system}.default;
            };
          in
          [
            inputs.home.darwinModules.home-manager

            home
            nix
          ];
      };
  };

in

builtins.mapAttrs
  (flip
    ({ extraModules ? [ ], hostname ? null, ... }@value: hostname':
    builtins.removeAttrs value [ "extraModules" "hostname" ] // {
      modules =
        let
          host = if hostname != null then hostname else hostname';
        in
        [
          # inputs.agenix.darwinModules.age

          {
            _module.args = specialArgs;
            nixpkgs.config = nixpkgsConfig;
            nixpkgs.overlays = nixpkgsOverlays;
          }
          ({ lib, ... }: { networking.hostName = lib.mkDefault host; })

          ../_common
          # ./_modules
          (./. + "/${host}/configuration.nix")
        ]
        ++ extraModules;
    }))
  machines
