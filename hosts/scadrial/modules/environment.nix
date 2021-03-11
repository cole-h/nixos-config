{ config, lib, pkgs, ... }:

{
  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs;
    [
      age
      agenix
      bc
      binutils
      # borgbackup
      cachix
      # cntr # used for breakpointHook
      # cryptsetup # for borgbackup
      dnsutils
      e2fsprogs
      evince
      ffmpeg
      file
      # filezilla # for switch
      gcc
      gdb
      git
      git-crypt
      gnome3.file-roller
      gnome3.nautilus # GUI file manager
      htop
      imagemagick
      kakoune
      libressl.nc # netcat-openbsd
      lsof
      man-pages
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
      posix_man_pages
      psmisc
      rsync
      strace
      usbutils
      wireguard-tools
      xdg-utils
      zathura

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

  # For nix-direnv (https://github.com/nix-community/nix-direnv)
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
}
