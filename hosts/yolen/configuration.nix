{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./modules
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.kernelParams = [ "net.ifnames=0" ];
  boot.zfs.devNodes = "/dev";
  boot.loader.grub.device = "/dev/vda";

  networking = {
    domain = "helbling.dev";
    hostId = "423dd678";
    defaultGateway = "165.232.128.1";
    nameservers = [ "8.8.8.8" ];

    interfaces.eth0.ipv4.addresses = [{
      address = "165.232.137.100";
      prefixLength = 20;
    }];
  };

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  users.mutableUsers = false;
  users.users = {
    hoid = {
      isNormalUser = true;
      uid = 1000;
      openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
      hashedPassword = "$6$5ixP2MjKpzZJZ$TaT/4jn1MGdqaQ4twwKuYkC7opYQf.kO5t6bgADSvBDF57UGCzHtXygnsnlxG3ULNIaCJbHy9zGfV.Jvqmxai/";

      extraGroups = [
        "wheel"
      ];
    };

    root = {
      hashedPassword = null;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh vin@scadrial"
      ];
    };
  };

  nix.package = pkgs.nixUnstable;

  security.doas.enable = true;

  environment.systemPackages = with pkgs;
    [
      git
      kakoune
      htop
    ];

  system.stateVersion = "21.05";
}
