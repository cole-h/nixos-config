let
  sources = import ./nix/sources.nix;
  pinnedPkgs = import sources.nixpkgs { };
in
{
  network.description = "Cosmere";
  network.enableRollback = true;
  network.nixpkgs = pinnedPkgs;

  scadrial =
    { ... }:
    {
      imports = [
        ./hosts/scadrial/configuration.nix
      ];

      deployment.targetHost = "localhost";
      deployment.privilegeEscalationCommand = [ "doas" ];
    };
}
