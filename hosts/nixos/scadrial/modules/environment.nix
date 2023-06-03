{ config, lib, pkgs, ... }:

{
  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs;
    [
      agenix # secrets
      age # secrets
      binutils # ld, strip
      efibootmgr
      evince # pdf viewer
      gcc # compilation, but also for rust
      gdb # debugging
      gitFull # ...git
      gnome.file-roller # gui archive manager
      gnome.nautilus # GUI file manager
      libressl.nc # netcat-openbsd
      man-pages # man-pages stuff
      man-pages-posix # posix man pages
      musl.dev # for musl-gcc, static compilation of rust programs
      pavucontrol # volume gui
      pciutils # lspci, etc
      psmisc # ps
      strace # trace syscalls and stuff
      usbutils # lsusb
      wireguard-tools # wg, etc.
      xdg-utils # xdg-mime, xdg-open
      zathura # minimal pdf viewer
    ];
}
