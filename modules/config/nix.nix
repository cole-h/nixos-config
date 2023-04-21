{ inputs, lib, ... }:
{
  nix = {
    nixPath = [ ];
    distributedBuilds = true; # necessary for settings.builders to not be defined in the nix-daemon upstream module
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      flake-registry = "/etc/nix/registry.json";
      builders = [ "@/etc/nix/machines" ];
      trusted-public-keys = [
        "scadrial:3FwW08DNiVlNfDWCuBMesZDLISmsgutOLdUt111uvU4="
      ];
    };

    registry = {
      self = {
        flake = inputs.self;
      };

      nixpkgs = {
        from = { id = "nixpkgs"; type = "indirect"; };
        flake = inputs.nixpkgs;
      };
    };
  };
}
