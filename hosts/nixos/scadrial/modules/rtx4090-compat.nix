{ config, lib, pkgs, ... }:
{
  boot.kernelParams = [
    "module_blacklist=i915,xe"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = false;
  hardware.nvidia.powerManagement.finegrained = false;
  hardware.nvidia.open = true;
  hardware.nvidia.nvidiaSettings = true;
}
