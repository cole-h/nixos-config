{ pkgs, lib, ... }:
{
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 128;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 1;
    supportedFilesystems = [ "zfs" "ntfs" ]; # allows r/w ntfs
    initrd.kernelModules = [ "nouveau" ]; # load nouveau early for native res tty
    tmpOnTmpfs = true;
    # plymouth.enable = true; # requires https://github.com/NixOS/nixpkgs/pull/88789

    kernelPackages = pkgs.linuxPackages_zen;
    extraModulePackages = [ pkgs.linuxPackages_zen.v4l2loopback ];
    # FIXME: doesn't seem to work? only a manual `modprobe ...` makes
    # v4l2loopback show up in lsmod
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
      # options snd-hda-intel vid=8086 pid=8ca0 snoop=0
      # options snd_hda_intel vid=8086 pid=8ca0 snoop=0
    '';

    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "kernel.printk" = "3 4 3 3"; # don't let logging bleed into TTY
    };

    kernelParams = [
      "udev.log_priority=3"
    ];

    # Allow emulated cross compilation for aarch64
    # binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
