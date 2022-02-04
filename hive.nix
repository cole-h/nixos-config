{ inputs }:
let
  inherit (inputs.nixpkgs)
    lib
    ;

  inherit (inputs.self.lib)
    pkgsFor
    ;

  hosts = builtins.removeAttrs
    (import ./hosts { inherit inputs; })
    [ "bootstrap" ];
in
{
  meta = {
    nixpkgs = {
      inherit lib;
      path = inputs.nixpkgs;
    };

    nodeNixpkgs = builtins.mapAttrs
      (hostname: value:
        pkgsFor {
          inherit inputs;
          inherit (value) system;
          inherit (inputs) nixpkgs;
        })
      hosts;
  };
} // builtins.mapAttrs
  (hostname: value:
    {
      deployment = {
        privilegeEscalationCommand = [ "sudo" ];
        targetHost = hostname;
        targetUser = "deploy";
      };

      imports = value.modules;
    })
  hosts
