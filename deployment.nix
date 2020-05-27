{
  network.description = "Cosmere";
  network.enableRollback = true;

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
