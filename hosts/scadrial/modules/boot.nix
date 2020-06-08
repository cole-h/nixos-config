{ pkgs, lib, ... }:
let
  linux_zen_pkg = { fetchurl, buildLinux, ... }@args:
    buildLinux (args // rec {
      version = "5.6.15-zen2";
      modDirVersion = version;

      # https://github.com/zen-kernel/zen-kernel/releases
      src = fetchurl {
        url = "https://github.com/zen-kernel/zen-kernel/archive/v${version}.tar.gz";
        sha256 = "1s92q7kp0brl5x31b11j9mrh3cmgl0k6jaq8w8p9rpwmgpq2vpk7";
      };

      kernelPatches = [ ];
      extraMeta.branch = "5.6";
    } // (args.argsOverride or { }));
  linux_zen = pkgs.callPackage linux_zen_pkg { };
  linuxPackages_zen = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_zen);
in
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.supportedFilesystems = [ "zfs" "ntfs" ];
  boot.initrd.kernelModules = [ "nouveau" ];
  boot.tmpOnTmpfs = true;
  boot.plymouth.enable = true;

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = linuxPackages_zen;
  boot.extraModulePackages = [ linuxPackages_zen.v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
    # options snd-hda-intel vid=8086 pid=8ca0 snoop=0
    # options snd_hda_intel vid=8086 pid=8ca0 snoop=0
  '';

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
