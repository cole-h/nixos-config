{ inputs
}:
let
  inherit (inputs.self.lib)
    specialArgs
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
              nix.package = lib.mkForce inputs.nix.packages.${system}.default;
              nix.settings.experimental-features = [ "nix-command" "flakes" ];
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

            { _module.args = specialArgs; }
            ({ lib, ... }: { networking.hostName = lib.mkDefault host; })

            ../modules
            (./. + "/${host}/configuration.nix")
          ]
          ++ extraModules;
      }))
  machines
