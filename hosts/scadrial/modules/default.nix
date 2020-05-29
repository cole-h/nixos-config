{ ... }:

{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./networking.nix
    ./programs.nix # misc, short program settings
    ./services.nix # misc, short service settings
    ./torrent.nix

    ./libvirt
  ];
}
