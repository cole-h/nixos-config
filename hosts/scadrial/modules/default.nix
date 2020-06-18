{ ... }:

{
  imports = [
    # ./borg

    ./boot.nix
    ./hardware.nix
    ./networking.nix
    ./packages.nix
    ./programs.nix # misc, short program settings
    ./security.nix
    ./services.nix # misc, short service settings
    ./torrent.nix
    ./users.nix

    ./libvirt
  ];
}
