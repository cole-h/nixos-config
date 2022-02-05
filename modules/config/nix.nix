{ inputs, ... }:
{
  nix = {
    nixPath = [
      "nixpkgs=${inputs.self}/compat"
      "nixos-config=${inputs.self}/compat/nixos"
    ];

    settings = {
      flake-registry = "/etc/nix/registry.json";
      trusted-public-keys = [
        "scadrial:3FwW08DNiVlNfDWCuBMesZDLISmsgutOLdUt111uvU4="
      ];
    };

    registry = {
      self.flake = inputs.self;

      nixpkgs = {
        from = { id = "nixpkgs"; type = "indirect"; };
        flake = inputs.nixpkgs;
      };
    };
  };
}
