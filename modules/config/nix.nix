{ inputs, lib, ... }:
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
      self = {
        to = { type = "path"; path = "${inputs.self}"; }
          // lib.filterAttrs
          (n: _: n == "lastModified" || n == "rev" || n == "revCount" || n == "narHash")
          inputs.self;
      };

      nixpkgs = {
        from = { id = "nixpkgs"; type = "indirect"; };
        to = { type = "path"; path = "${inputs.nixpkgs}"; }
          // lib.filterAttrs
          (n: _: n == "lastModified" || n == "rev" || n == "revCount" || n == "narHash")
          inputs.nixpkgs;
      };
    };
  };
}
