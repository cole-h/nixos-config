{ pkgs, lib, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.kernelModules = [ "nouveau" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.tmpOnTmpfs = true;
  # TODO: encrypt zfs dataset lol
  # boot.zfs.requestEncryptionCredentials = true;

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  boot.kernelParams = lib.mkBefore [
    "quiet"
    "udev.log_priority=3"
    "elevator=none" # recommended for ZFS: https://grahamc.com/blog/nixos-on-zfs
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
