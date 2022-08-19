{ config, pkgs, lib, ... }:
{
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 128;
    loader.systemd-boot.consoleMode = "max"; # 1920x1080? poggers
    loader.systemd-boot.memtest86.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 1;
    supportedFilesystems = [ "zfs" "ntfs" ]; # allows r/w ntfs
    initrd.kernelModules = [ "amdgpu" ]; # load amdgpu early to prevent flickering
    tmpOnTmpfs = true;
    cleanTmpDir = true;
    # plymouth.enable = true; # requires https://github.com/NixOS/nixpkgs/pull/88789

    zfs.requestEncryptionCredentials = [ "apool/ROOT" ];
    zfs.forceImportRoot = false;

    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
    '';

    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "kernel.printk" = "3 4 3 3"; # don't let logging bleed into TTY
    };

    kernelParams = [
      "udev.log_priority=3"
    ];

    # Allow emulated cross compilation for aarch64
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
