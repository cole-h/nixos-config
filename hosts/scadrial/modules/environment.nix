{ config, lib, pkgs, ... }:

{
  environment.pathsToLink = [ "/share/zsh" ];
  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs;
    [
      agenix # secrets
      age # secrets
      bat # cat but better
      binutils # ld, strip
      # borgbackup
      bottom # fancy top
      # cachix
      # cntr # used for breakpointHook
      # cryptsetup # for borgbackup
      dnsutils
      dogdns # dig but better
      efibootmgr
      evince # pdf viewer
      exa # ls but better
      fd # find files
      ffmpeg # video conversion and stuff
      file # check file types
      # filezilla # for switch
      gcc # compilation, but also for rust
      gdb # debugging
      gitFull # ...git
      gnome.file-roller # gui archive manager
      gnome.nautilus # GUI file manager
      hexyl # hex viewer
      htop # top but better
      imagemagick # cli image manipulation
      libqalculate # greatest cli calculator ever, with conversions too
      # libreoffice # Office but worse
      libressl.nc # netcat-openbsd
      man-pages # man-pages stuff
      man-pages-posix # posix man pages
      ncdu # friendlier du
      nix-index # nix-locate
      nixpkgs-fmt # the better formatter
      nix-top # see what's building
      # openconnect # for school VPN, if needed
      openssl # playing with tls and more
      par # nice paragraph formatter
      pavucontrol # volume gui
      pciutils # lspci, etc
      psmisc # ps
      ripgrep # grep but better; [overlays]
      rsync # send files over ssh
      strace # trace syscalls and stuff
      # tmate # "Instant Terminal Sharing"
      tokei # code metrics
      usbutils # lsusb
      wireguard-tools # wg, etc.
      xdg-utils # xdg-mime, xdg-open
      # zathura # fails to build: https://github.com/NixOS/nixpkgs/issues/187305
    ];
}
