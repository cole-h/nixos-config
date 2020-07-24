{ ... }:

{
  imports = [
    # ./borg # configuration related to running an ofborg instance

    ./boot.nix # configuration related to boot
    ./hardware.nix # configuration related to hardware
    ./networking.nix # configuration related to networking
    ./packages.nix # configuration related to packages
    ./programs.nix # misc, short program settings
    ./security.nix # configuration related to general security
    ./services.nix # misc, short service settings
    ./torrent.nix # configuration related to torrenting
    ./users.nix # configuration related to users
    ./wireguard.nix # configuration related to wireguard

    ./libvirt # configuration related to libvirt and vfio + pci passthrough
  ];
}