{ config, lib, pkgs, ... }:

{
  environment.pathsToLink = [ "/share/zsh" ];
  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs;
    [
      age
      agenix
      binutils
      # borgbackup
      cachix
      # cntr # used for breakpointHook
      # cryptsetup # for borgbackup
      dnsutils
      e2fsprogs
      efibootmgr
      evince
      ffmpeg
      file
      # filezilla # for switch
      gcc
      gdb
      git
      gnome.file-roller
      gnome.nautilus # GUI file manager
      htop
      imagemagick
      kakoune
      libressl.nc # netcat-openbsd
      libqalculate
      lsof
      man-pages
      man-pages-posix
      minisign
      ncdu
      neovim
      nix-index
      nixpkgs-fmt
      nix-prefetch
      nix-prefetch-scripts
      nix-top
      openssl
      par # nice paragraph formatter
      pavucontrol
      pciutils
      psmisc
      rsync
      strace
      usbutils
      wireguard-tools
      xdg-utils
      # zathura # fails to build: https://github.com/NixOS/nixpkgs/issues/187305

      bat # cat but better
      bottom # fancy top
      exa # ls but better
      fd # find files
      hexyl # hex viewer
      # libreoffice # Office but worse
      # openconnect # for school VPN, if needed
      ripgrep # grep but better; [overlays]
      # tmate # "Instant Terminal Sharing"
      tokei # code metrics
    ];
}
