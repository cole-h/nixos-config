{
  network.description = "Cosmere";

  scadrial =
    { ... }:
    {
      imports = [
        ./scadrial/configuration.nix
      ];

      deployment.targetHost = "localhost";
    };
}
