{ config, pkgs, lib, ... }:
# 1. Create SD image with https://github.com/Mic92/nixos-aarch64-images
# 2. Flash to SD with `dd if=result of=/dev/sdg oflag=direct bs=16M status=progress`
# 3. Boot Rock64 with SD, connect everything
# 4. follow setup
# 5. TODO:
{
  imports =
    [
      ./hardware-configuration.nix
      ./modules
    ];

  boot = {
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  security.doas.enable = true;

  services.openssh.enable = true;
  services.openssh.extraConfig = "StreamLocalBindUnlink yes";

  environment.systemPackages = with pkgs;
    [
      git
      htop
      kakoune
      wol
    ];

  # TODO:
  # swapDevices = [ { device = "/swapfile"; size = 4096; } ];

  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "21.05";
}
