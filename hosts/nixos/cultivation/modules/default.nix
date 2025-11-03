{ config, pkgs, ... }:
{
  imports =
    [
      ./networking.nix
      # ./nix.nix
      ./samba.nix
      ./users.nix

      ./downloads
      # ./wireguard
      ./zrepl
    ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_6_17;
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "bpool" ];
    zfs.requestEncryptionCredentials = [ "bpool" ];
    zfs.package = pkgs.zfs_unstable;
  };

  security.doas.enable = true;

  services.openssh.enable = true;
  services.openssh.extraConfig = "StreamLocalBindUnlink yes";

  environment.systemPackages = with pkgs;
    [
      git
      htop
      wol
      helix
    ];
}
