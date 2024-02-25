{ lib, pkgs, ... }:
{
  boot.kernelParams = [
    "module_blacklist=i915"
  ];
}
