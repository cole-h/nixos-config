{ ... }:

{
  imports =
    [
      # ./borg # configuration related to running an ofborg instance
      # ./gnome.nix # configuration related to GNOME

      ./boot.nix # configuration related to boot
      ./downloads.nix # configuration related to torrenting
      ./environment.nix # configuration related to environment.*
      ./filesystems.nix # configuration related to filesystems
      ./fonts.nix # configuration related to fonts
      ./hardware.nix # configuration related to hardware
      ./networking.nix # configuration related to networking
      ./nix.nix # configuration related to Nix itself
      ./programs.nix # misc, short program settings
      ./security.nix # configuration related to general security
      ./services.nix # misc, short service settings
      # ./smb.nix # configuration related to Samba
      ./users.nix # configuration related to users

      ./libvirt # configuration related to libvirt and vfio + pci passthrough
      ./wireguard # configuration related to wireguard
    ];
}
