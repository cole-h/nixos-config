{ pkgs, lib, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.supportedFilesystems = [ "zfs" "ntfs" ];
  boot.initrd.kernelModules = [ "nouveau" ];
  boot.tmpOnTmpfs = true;
  boot.plymouth.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages =
  #   let
  #     linux_zen_pkg = { fetchurl, buildLinux, ... }@args:
  #       buildLinux (args // rec {
  #         version = "5.6.15-zen1";
  #         modDirVersion = version;

  #         # https://github.com/zen-kernel/zen-kernel/releases
  #         src = fetchurl {
  #           url = "https://github.com/zen-kernel/zen-kernel/archive/v${version}.tar.gz";
  #           sha256 = "0bjjrsblmgz00vrrnqgc52dyp4g81klsmvi87zv50yhmvlcd7h9n";
  #         };

  #         kernelPatches = [ ];
  #         extraMeta.branch = "5.6";
  #       } // (args.argsOverride or { }));
  #     linux_zen = pkgs.callPackage linux_zen_pkg { };
  #   in
  #   pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_zen);

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "kernel.printk" = "3 4 3 3"; # don't let logging bleed into TTY
  };

  boot.kernelParams = [
    "udev.log_priority=3"
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
