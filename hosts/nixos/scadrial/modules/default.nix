{ ... }:

{
  imports =
    [
      ./environment.nix # configuration related to environment.*
      ./fonts.nix # configuration related to fonts
      ./hardware.nix # configuration related to hardware
      ./networking.nix # configuration related to networking
      ./nix.nix # configuration related to Nix itself
      ./programs.nix # misc, short program settings
      ./security.nix # configuration related to general security
      ./services.nix # misc, short service settings
      ./users.nix # configuration related to users
      ./rtx4090-compat.nix # configuration related to making my 4090 + nouveau work
      ./ime.nix # configuration related to setting up an ime

      ./boot # configuration related to boot
      ./downloads # configuration related to torrenting
      ./libvirt # configuration related to libvirt and vfio + pci passthrough
      ./zrepl # configuration related to zrepl

      ./test # temporary testing configuration
    ];
}
