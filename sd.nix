# Configuration for (re)installing NixOS on aarch64.
# nix build .#sd
{ pkgs, lib, modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/installer/cd-dvd/sd-image-aarch64-new-kernel.nix")
    ];

  nix.package = pkgs.nixUnstable;

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableBrowserSocket = true;
  #   enableExtraSocket = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "curses";
  # };

  security.doas.enable = true;

  environment.systemPackages = with pkgs;
    [
      git
      git-crypt
      neovim
      kakoune
      htop
    ];

  networking = {
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [
      {
        address = "192.168.1.69";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.212" "1.1.1.1" ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH6wCrUu1DHKFqeiRxNvIvv41rE5zS9rdingyKtZX5gy openpgp:0xF208643A"
  ];

  sdImage.compressImage = false;
  # systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  services.sshd.enable = true;
}
