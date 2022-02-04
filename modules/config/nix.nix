{ inputs, ... }:
{
  nix = {
    # print-build-logs = true
    # log-format = bar-with-logs
    extraOptions = ''
      flake-registry = /etc/nix/registry.json
    '';

    nixPath = [
      "nixpkgs=${inputs.self}/compat"
      "nixos-config=${inputs.self}/compat/nixos"
    ];

    registry = {
      self.flake = inputs.self;

      nixpkgs = {
        from = { id = "nixpkgs"; type = "indirect"; };
        flake = inputs.nixpkgs;
      };
    };
  };
}
