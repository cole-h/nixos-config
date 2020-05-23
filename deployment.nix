{
  network.description = "Cosmere";

  scadrial =
    { ... }:
    {
      imports = [
        ./hosts/scadrial/configuration.nix
      ];

      deployment.targetHost = "localhost";
    };
}
