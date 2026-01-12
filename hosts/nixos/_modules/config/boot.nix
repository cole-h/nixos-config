{ config, pkgs, ... }:
{
  boot = {
    # NOTE(cole-h): Do _not_ let this slide back to a version before 6.7/6.8 -- scadrial will not
    # get graphics with its 4090...
    kernelPackages = pkgs.linuxKernel.packages.linux_6_18;
    supportedFilesystems = [ "zfs" ];
    zfs.package = pkgs.zfs_unstable;
  };
}
