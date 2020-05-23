{ pkgs, lib, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.kernelModules = [ "nouveau" ];
  boot.tmpOnTmpfs = true;

  boot.kernelPackages =
    let
      linux_zen_pkg = { fetchurl, buildLinux, ... }@args:
        buildLinux (args // rec {
          version = "5.6.14-zen1";
          modDirVersion = version;

          # https://github.com/zen-kernel/zen-kernel/releases
          src = fetchurl {
            url = "https://github.com/zen-kernel/zen-kernel/archive/v${version}.tar.gz";
            sha256 = "1c3vr0kg7wp4f9yscp6g0c4avjnahfjwlpam04q4sj60zb2zdgdc";
          };

          kernelPatches = [ ];
          extraMeta.branch = "5.6";
        } // (args.argsOverride or { }));
      linux_zen = pkgs.callPackage linux_zen_pkg { };
    in
    pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_zen);

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  boot.kernelParams = lib.mkBefore [
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
