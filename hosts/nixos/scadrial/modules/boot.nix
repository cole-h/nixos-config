{ config, pkgs, lib, ... }:
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 128;
  boot.loader.systemd-boot.consoleMode = "max"; # 1920x1080? poggers
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.supportedFilesystems = [
    "zfs"
    "ntfs" # allows r/w ntfs
  ];

  boot.zfs.requestEncryptionCredentials = [ "apool/ROOT" ];
  boot.zfs.forceImportRoot = false;

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
  '';

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
    "kernel.printk" = "3 4 3 3"; # don't let logging bleed into TTY
  };

  boot.kernelParams = [
    "udev.log_priority=3"
  ];

  # Allow emulated cross compilation for aarch64
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  # Clean up /tmp and other systemd-tmpfiles-controlled places before shutting down.
  systemd.services."cleanup-tmp-before-poweroff" = {
    before = [ "final.target" ];
    wantedBy = [ "final.target" ];

    unitConfig = {
      DefaultDependencies = false;
    };

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.systemd.package}/bin/systemd-tmpfiles --clean";
    };
  };
}
