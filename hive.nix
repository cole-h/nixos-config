{ inputs }:
let
  inherit (inputs.nixpkgs)
    lib
    ;

  inherit (inputs.self.lib)
    pkgsFor
    specialArgs
    ;

  hosts = builtins.removeAttrs
    (import ./hosts { inherit inputs; })
    [ "bootstrap" ];
in
{
  meta = {
    inherit specialArgs;

    nixpkgs = {
      inherit lib;
    };

    nodeNixpkgs = builtins.mapAttrs
      (hostname: value:
        pkgsFor {
          inherit inputs;
          inherit (value) system;
          inherit (inputs) nixpkgs;
        } // {
          # For whatever reason, `system` doesn't get set...?
          inherit (value) system;
        })
      hosts;
  };
} // builtins.mapAttrs
  (hostname: value:
    {
      deployment = {
        privilegeEscalationCommand = [ "sudo" ];
        targetHost = "${hostname}.local";
        targetUser = "deploy";
      };

      imports = value.modules;
    })
  hosts
