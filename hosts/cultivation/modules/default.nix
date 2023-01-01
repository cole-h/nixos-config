{ config, pkgs, ... }:
{
  imports =
    [
      ./networking.nix
      ./nix.nix
      ./samba.nix
      ./users.nix

      ./downloads
      # ./wireguard
      ./zrepl
    ];

  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "bpool" ];
    zfs.requestEncryptionCredentials = [ "bpool" ];
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
