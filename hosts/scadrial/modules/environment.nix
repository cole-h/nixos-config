{ config, lib, pkgs, ... }:

{
  environment.pathsToLink = [ "/share/zsh" ];
  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs;
    [
      agenix # secrets
      age # secrets
      binutils # ld, strip
      bottom # fancy top
      dnsutils # dig, nslookup
      efibootmgr
      evince # pdf viewer
      exa # ls but better
      fd # find files
      ffmpeg # video conversion and stuff
      file # check file types
      gcc # compilation, but also for rust
      gdb # debugging
      gitFull # ...git
      gnome.file-roller # gui archive manager
      gnome.nautilus # GUI file manager
      hexyl # hex viewer
      htop # top but better
      libqalculate # greatest cli calculator ever, with conversions too
      libressl.nc # netcat-openbsd
      man-pages # man-pages stuff
      man-pages-posix # posix man pages
      musl.dev # for musl-gcc, static compilation of rust programs
      ncdu # friendlier du
      nix-index # nix-locate
      nixpkgs-fmt # the better formatter
      nix-top # see what's building
      openssl # playing with tls and more
      par # nice paragraph formatter
      pavucontrol # volume gui
      pciutils # lspci, etc
      psmisc # ps
      ripgrep # grep but better
      rsync # send files over ssh
      strace # trace syscalls and stuff
      tokei # code metrics
      usbutils # lsusb
      wireguard-tools # wg, etc.
      xdg-utils # xdg-mime, xdg-open
      zathura # minimal pdf viewer
    ];
}
