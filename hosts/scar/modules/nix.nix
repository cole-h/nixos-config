{ pkgs, ... }:
{
  nix.package = pkgs.nixUnstable;
  nix.distributedBuilds = true;

  nix.binaryCaches = [
    "ssh-ng://builder"
  ];

  nix.binaryCachePublicKeys = [
    "scadrial:3FwW08DNiVlNfDWCuBMesZDLISmsgutOLdUt111uvU4="
  ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    builders-use-substitutes = true
  '';

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
