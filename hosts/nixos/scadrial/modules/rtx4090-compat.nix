{ lib, pkgs, ... }:
let
  version = "2.2.3-unstable-2024-01-30";
  src = pkgs.fetchFromGitHub {
    owner = "openzfs";
    repo = "zfs";
    rev = "eeab554b8a07363bfe8f9a064811d06219f4f0f6";
    hash = "sha256-s9xAP+RJDJdyu9jAS2OkogS1FR9VRd70yQCBJpPO5iw=";
  };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      zfs = prev.zfs.overrideAttrs ({ ... }: {
        name = "zfs-user-${version}";
        inherit src;
      });
    })
  ];

  # FIXME: once linux 6.7 is released and in nixpkgs, AND ZFS supports 6.7 kernels
  # https://github.com/NixOS/nixpkgs/pull/271703
  # https://github.com/openzfs/zfs/issues/15582
  boot.kernelPackages =
    let
      kernelPackage = pkgs.linuxKernel.packages.linux_6_7.kernel;
      linuxPackages = (pkgs.linuxPackagesFor kernelPackage).extend
        (final: prev: {
          zfs = prev.zfs.overrideAttrs ({ ... }: {
            name = "zfs-kernel-${version}-${final.kernel.version}";
            inherit src;
            meta.broken = false;
          });
        });
    in
    lib.mkForce (pkgs.recurseIntoAttrs linuxPackages);

  boot.kernelParams = [
    "module_blacklist=i915"
  ];
}
