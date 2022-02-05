{ pkgs, ... }:
{
  nix.distributedBuilds = true;

  nix.settings.substituters = [
    "ssh-ng://builder"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "builder";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      maxJobs = 16;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];
}
