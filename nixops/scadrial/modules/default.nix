{ ... }:

{
  imports = [
    ./torrent.nix
    ./boot.nix
    ./networking.nix
    ./hardware.nix
    ./services.nix # misc, short service settings

    ./libvirt
  ];
}
