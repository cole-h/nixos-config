{ inputs
}:
rec {
  linuxSystems = [ "x86_64-linux" ];
  darwinSystems = [ "aarch64-darwin" ];
  allSystems = linuxSystems ++ darwinSystems;

  nameValuePair = name: value: { inherit name value; };
  genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);

  nixpkgsConfig = {
    allowAliases = false;
    allowUnfree = true;
  };

  nixpkgsOverlays = [
    (import ./overlay.nix { inherit inputs; })
    (final: prev: {
      agenix = inputs.agenix-cli.defaultPackage.${final.stdenv.system};
    })
  ];

  pkgsFor =
    { nixpkgs
    , system
    }:
    import nixpkgs {
      inherit system;
      config = nixpkgsConfig;
      overlays = nixpkgsOverlays;
    };

  forAllSystems = f: genAttrs allSystems
    (system: f {
      inherit system;
      pkgs = pkgsFor {
        inherit system;
        inherit (inputs) nixpkgs;
      };
    });

  specialArgs = {
    inherit inputs;

    my = import ../my.nix {
      inherit (inputs.nixpkgs) lib;
    };

    secretsPath = ../secrets;
  };

  mkNixosSystem =
    { system
    , modules
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system modules specialArgs;
    };

  mkDarwinSystem =
    { system
    , modules
    }:
    inputs.darwin.lib.darwinSystem {
      inherit system modules specialArgs;
    };
}
