let
  sources = import ./nix/sources.nix;
  pinnedPkgs = import sources.nixpkgs { };
in
{
  network.description = "Cosmere";
  network.enableRollback = true;
  # TODO: make sure this also allows stuff to work without a NIX_PATH
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
