let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
in
{
  network.description = "Cosmere";
  network.enableRollback = true;

  scadrial =
    { ... }:
    {
      imports = [
        ./hosts/scadrial/configuration.nix
      ];

      # nixpkgs.pkgs = pkgs;

      deployment.targetHost = "localhost";
      deployment.privilegeEscalationCommand = [ "doas" ];
    };
}
