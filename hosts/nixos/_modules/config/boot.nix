{ config, pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_17;
    supportedFilesystems = [ "zfs" ];
    zfs.package = pkgs.zfs_unstable;
  };
}
