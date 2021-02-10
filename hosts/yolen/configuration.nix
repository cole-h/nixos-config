{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
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
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH6wCrUu1DHKFqeiRxNvIvv41rE5zS9rdingyKtZX5gy openpgp:0xF208643A"
  ];

  users.mutableUsers = false;
  users.users.hoid = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
    hashedPassword = "$6$5ixP2MjKpzZJZ$TaT/4jn1MGdqaQ4twwKuYkC7opYQf.kO5t6bgADSvBDF57UGCzHtXygnsnlxG3ULNIaCJbHy9zGfV.Jvqmxai/";

    extraGroups = [
      "wheel"
    ];
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

  ### MAIL
  mailserver =
    let
      domain = config.networking.domain;
    in
    {
      enable = false;
      mailDirectory = "/var/lib/mail";
      dkimKeyDirectory = "/var/lib/dkim";
      fqdn = "mail.${domain}";
      domains = [ domain ];

      loginAccounts = {
        "cole@${domain}" = {
          hashedPasswordFile = "";

          aliases = [
            "postmaster@${domain}"
            "abuse@${domain}"
            "admin@${domain}"
          ];
        };
      };

      # Use Let's Encrypt certificates.
      certificateScheme = 3;

      # Enable IMAP and POP3
      enableImap = true;
      enablePop3 = true;
      enableImapSsl = true;
      enablePop3Ssl = true;

      # Enable the ManageSieve protocol
      enableManageSieve = true;
    };
}
