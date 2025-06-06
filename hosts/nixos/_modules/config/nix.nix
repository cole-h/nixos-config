{ inputs, lib, ... }:
{
  nix = {
    nixPath = [ ];
    distributedBuilds = true; # necessary for settings.builders to not be defined in the nix-daemon upstream module
    settings = {
      lazy-trees = true;
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "/etc/nix/registry.json";
      builders = [ "@/etc/nix/machines" ];
      extra-substituters = ["https://ghostty.cachix.org"];
      extra-trusted-public-keys = [
        "scadrial:3FwW08DNiVlNfDWCuBMesZDLISmsgutOLdUt111uvU4="
        "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
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
