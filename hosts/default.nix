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
    scadrial =
      let
        system = "x86_64-linux";
      in
      {
        inherit system;

        extraModules =
          let
            home = { config, ... }: {
              home-manager = {
                users = import ../users;
                useGlobalPkgs = true;
                useUserPackages = true;
                verbose = true;

                extraSpecialArgs = specialArgs // {
                  super = config;
                };
              };
            };

            nix = { lib, ... }: {
              nix.package = lib.mkForce inputs.nix.packages.${system}.default;
            };
          in
          [
            inputs.home.nixosModules.home-manager

            home
            nix
          ];
      };

    cultivation = {
      system = "x86_64-linux";
    };

    bootstrap = {
      system = "x86_64-linux";
      hostname = "scadrial";
      extraModules = [
        # { age.sshKeyPaths = [ "/tmp/host/ed25519" ]; }
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
          inputs.agenix.nixosModules.age

          {
            _module.args = specialArgs;
            nixpkgs.config = nixpkgsConfig;
            nixpkgs.overlays = nixpkgsOverlays;
          }
          ({ lib, ... }: { networking.hostName = lib.mkDefault host; })

          ../modules
          (./. + "/${host}/configuration.nix")
        ]
        ++ extraModules;
    }))
  machines
