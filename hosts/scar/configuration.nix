{ config, pkgs, lib, inputs, ... }:
# 1. Create SD image with https://github.com/Mic92/nixos-aarch64-images
# 2. Flash to SD with `dd if=result of=/dev/sdg oflag=direct bs=16M status=progress`
# 3. Boot Rock64 with SD, connect everything
# 4. follow setup
# 5. TODO:
#
# NOTE: "Default" memory trainings may lead to memory corruption; see
# https://github.com/NixOS/nixpkgs/pull/145506#issuecomment-979585121 and the
# rest of that PR thread for more information.
{
  imports =
    [
      ./hardware-configuration.nix
      ./modules
    ];

  boot = {
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "bpool" ];
    zfs.requestEncryptionCredentials = [ "bpool" ];
  };

  security.doas.enable = true;

  services.openssh.enable = true;
  services.openssh.extraConfig = "StreamLocalBindUnlink yes";

  environment.systemPackages = with pkgs;
    [
      git
      htop
      wol
    ];

  fileSystems."/data".options = [ "nofail" ];

  # TODO:
  # swapDevices = [ { device = "/swapfile"; size = 4096; } ];

  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "21.05";
}
