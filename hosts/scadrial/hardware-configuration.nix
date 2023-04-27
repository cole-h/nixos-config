# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "apool/ROOT/system/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "apool/ROOT/local/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "apool/ROOT/user/home";
      fsType = "zfs";
    };

  fileSystems."/home/vin" =
    { device = "apool/ROOT/user/home/vin";
      fsType = "zfs";
    };

  fileSystems."/home/vin/Downloads" =
    { device = "apool/ROOT/user/home/vin/Downloads";
      fsType = "zfs";
    };

  fileSystems."/home/vin/Games" =
    { device = "apool/ROOT/user/home/vin/Games";
      fsType = "zfs";
    };

  fileSystems."/home/vin/workspace/detsys" =
    { device = "apool/ROOT/user/home/vin/workspace/detsys";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "apool/ROOT/system/var";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0279-A3C4";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/6ffb5a36-79fd-4a70-9ffb-b8984643c8de"; }
    ];

}
