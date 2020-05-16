{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules
    ./options.nix
  ];

  programs = {
    home-manager = {
      enable = true;
      path = "${config.home.homeDirectory}/workspace/vcs/home-manager";
    };
  };

  xdg.enable = true;

  home = {
    enableDebugInfo = true;

    extraOutputsToInstall = [
      "man"
    ];

    packages = with pkgs; [
      ## nix-related
      # cachix
      # cntr # used for breakpointHook
      direnv
      niv
      nix # adds nix.sh to .nix-profile/etc/profile.d, which sets path stuff, which allows us to use binaries
      nix-index
      nixpkgs-fmt
      nix-prefetch-scripts
      nix-top
      lorri
      # nix-prefetch-github

      ## tools
      bat # cat but better
      exa # ls but better
      fd # find files
      ffsend # send files to Firefox Send from the terminal
      qimgv # image viewer
      ripgrep # grep but better; [overlays]
      skim # fzf-rs
      tokei # code metrics
      ytop # fancy top
      hexyl # hev viewer
      hyperfine # cli benchmarker
      aerc # terminal email reader (why tf does it bring emacs into its closure????)
      tmate # "Instant Terminal Sharing" -- for debugging darwin issues via GH Actions
      libreoffice

      # latest.firefox-beta-bin
      latest.firefox-nightly-bin
      pass-otp
      # android-studio # android apps

      newsboat # rss/atom feed reader

      ## misc
      chatterino2 # Twitch chat client; [drvs]
      discord
      todo-txt-cli # TODOs tracker

      #### User Packages
      # go # maybe
      evince
      zathura
      cadence
      pavucontrol
      # gitAndTools.hub
      # ncdu
      # rust-analyzer # (ra_lsp_server
      # lldb
      # kbd # showkey
      gnome3.networkmanagerapplet
      gnome3.nautilus # GUI file manager
      gnome3.file-roller
      foliate
      filezilla
      # streamlink
      # youtube-dl
      # cantata
      # texlive.combined.scheme-medium # texlive-core, texlive-most, texlive, auctex -- LaTeX stuff
      # ccls # C lsp server
      # binwalk

      #### System Packages
      # utillinux # (hexdump, lsblk, umount, blockdev, cfdisk
      # ffmpeg # (ffprobe)
      # bash
      # zsh
      # fish
      # psmisc # (killall)
      # netcat-openbsd # (nc)
      # coreutils # (tail, stat, kill, df, chmod, chown, head, ln, readlink, realpath, seq, shred, dirname
      # gdb
      # xdg_utils # (xdg-mime
      # file
      # ncurses # (tput, tic)
      # cups # (lpstat, lpadmin, ...) -- gutenprint + canon-pixma-m920-complete (aur)
      # binutils # (objdump, strip)
      # procps-ng # (watch, pkill, ps, pgrep, pidof
      # strace
      # alsaUtils # (aplay
      # gawk # (awk
      # gnused
      # bc
      # borgbackup # (borg)
      # bridge_utils # maybe unnecssary?
      # libarchive # (bsdtar
      # e2fsprogs # (chattr
      # imagemagick # (convert, mogrify)
      # dnsutils # (dig
      # findutils # (find
      # libcap # (getcap
      # acl # (getfacl
      # attr # (getfattr
      # iproute # (ip
      # glibc/musl # (ldd
      # less
      # kmod # (lsmod
      # openssl # (openssl base64 -d, openssl md5, etc)
      # openconnect # for school VPN, if needed
      # iputils # (ping, tracepath
      # wireguard # (wg, wg-quick
      # curl
      # htop
      # cryptsetup
      # ntfs3g
      # libguestfs # (guestmount,
      # libreoffice
      # lsof

      ## haskell stuff
      ## Switch USB stuff
      ## syncthing service
      ## qemu + libvirt + ovmf + virt-manager (vfio) + libvirt hooks
      ## sonarr, radarr, rtorrent + rutorrent (infinisil recommends transmission)
      ## udevmon or whatever for Caps -> Esc (or buy the Drop CTRL lol)
    ];

    activation = with lib; {
      # Some software requires fonts to be present in $XDG_DATA_HOME/fonts in
      # order to use/see them (like Emacs), so just link to them.
      # FIXME: remove me once migrate to NixOS
      setupFonts = hm.dag.entryAfter [ "writeBoundary" ] ''
        fontsdir="${config.home.profileDirectory}/share/fonts"
        userfontsdir="${config.xdg.dataHome}/fonts"

        # remove dead symlinks due to uninstalled font (e.g. all opentype fonts
        # are gone, leading to a broken link), etc.
        $DRY_RUN_CMD find $userfontsdir -xtype l \
          -exec echo unlinking {} \; -exec unlink {} \;

        # force necessary because of the many different fonts in colliding
        # directories
        for dir in $fontsdir/*; do
          $DRY_RUN_CMD unlink \
            $userfontsdir/$(basename $dir) 2>/dev/null || true
          $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
            $dir $userfontsdir/$(basename $dir)
        done
      '';
    };

    # NOTE: if you log in from a tty, make sure to erase __HM_SESS_VARS_SOURCED,
    # otherwise sessionVariables won't be sourced in new shells
    sessionVariables = rec {
      EDITOR = "nvim";
      VISUAL = EDITOR;

      # Path-related exports
      GOPATH = "${config.home.homeDirectory}/.go";
      CARGO_HOME = "${config.home.homeDirectory}/.cargo";
      # ANDROID_HOME = "${pkgs.androidenv.androidPks_9_0.androidsdk}/libexec/android-sdk";
      # DEVKITPRO = "/opt/devkitpro";
      # DEVKITARM = "${DEVKITPRO}/devkitARM";
      # DEVKITPPC = "${DEVKITPRO}/devkitPPC";

      # Use all processors :)
      MAKEFLAGS = "\${MAKEFLAGS:+$MAKEFLAGS }-j$(nproc)";

      # Solves locale issues on non-NixOS
      # FIXME: remove after switch to NixOS
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";

      # Add local conf and local nixpkgs to NIX_PATH
      # TODO: make config reproducible by cutting out NIX_PATH
      # (see: https://github.com/lovesegfault/nix-config/)
      # maybe investigate flakes
      # (see: https://github.com/nrdxp/nixflk/)
      NIX_PATH = lib.concatStringsSep ":" [
        "nixpkgs=${toString ~/workspace/vcs/nixpkgs/master}"
        # "nixpkgs-20.03=${toString ~/workspace/vcs/nixpkgs/release-20.03}"
      ];

      MPD_HOST = "127.0.0.1";
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "20.03";
  };

  # This enables workarounds and tweaks to increase the general cohesiveness of
  # the system when not on NixOS.
  # FIXME: remove after switch to NixOS
  targets.genericLinux.enable = true;

  services = {
    syncthing.enable = true;
  };

  systemd.user = {
    sessionVariables = {
      NIX_PATH = lib.mkForce config.home.sessionVariables.NIX_PATH;

      inherit (config.home.sessionVariables)
        LOCALE_ARCHIVE;
    };

    # FIXME: remove after switch to NixOS
    systemctlPath = "/usr/bin/systemctl";
  };
}
