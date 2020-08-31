{ pkgs, ... }:

{
  documentation.dev.enable = true;

  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs; [
    bc
    binutils
    borgbackup
    cntr # used for breakpointHook
    cryptsetup # for borgbackup
    dnsutils
    e2fsprogs
    ffmpeg
    file
    gdb
    git
    htop
    imagemagick
    iotop
    libarchive # maybe atool?
    # libreoffice
    lsof
    manpages
    mosh
    neovim
    netcat-openbsd
    openssl
    pciutils
    posix_man_pages
    psmisc
    strace
    usbutils
    wireguard
    xdg_utils
  ];
}
