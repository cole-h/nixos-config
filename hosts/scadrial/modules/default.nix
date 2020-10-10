{ ... }:

{
  imports =
    [
      # ./borg # configuration related to running an ofborg instance

      ./boot.nix # configuration related to boot
      ./environment.nix # configuration related to environment.*
      ./fonts.nix # configuration related to fonts
      # ./gnome.nix # configuration related to GNOME
      ./hardware.nix # configuration related to hardware
      ./networking.nix # configuration related to networking
      ./nix.nix # configuration related to Nix itself
      ./programs.nix # misc, short program settings
      ./security.nix # configuration related to general security
      ./services.nix # misc, short service settings
      ./smb.nix # configuration related to Samba
      ./torrent.nix # configuration related to torrenting
      ./users.nix # configuration related to users
      ./wireguard.nix # configuration related to wireguard

      ./libvirt # configuration related to libvirt and vfio + pci passthrough
    ];
}
