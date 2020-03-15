{ config, lib, pkgs, ... }:

{
  imports = [ ./modules ./options.nix ];

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

    # TODO: a lot of these should go in system packages once I switch to NixOS
    packages = with pkgs; [
      ## nix-related
      # cachix
      direnv
      niv
      nix # adds nix.sh to .nix-profile/etc/profile.d, which sets path stuff, which allows us to use binaries
      nix-index
      nixpkgs-fmt
      nix-top

      # glibcLocales # to deal with locale issues on non-NixOS

      ## system-related
      # musl

      ## tools
      bat
      exa
      fd
      ffsend
      qimgv
      ripgrep # [overlays]
      skim
      tokei
      ytop

      ## misc
      chatterino2 # Twitch chat client [drvs]

      # TODO: go through fish history and make a note of binaries
      #   general purpose binaries (like above and below) should probably go into system packages

      #### TODO: most of these become system packages on NixOS
      # curl
      # coreutils
      # evince
      # gdb
      # lldb
      # htop
      # TODO: doas and suid wrapper
      # switch USB stuff
      # need cups for printing, etc.; gutenprint + canon-pixma-m920-complete (aur)
      # cryptsetup + veracrypt for external TODO: buy larger external and move to luks2
      # need ntfs-3g + fuse for mounting NTFS (can be removed after switching backup drive to luks)
      # libguestfs, libguestfs-tools, libiscsi -- for vfio iSCSI
      # android stuff (probably just a lorri/nix-shell env)
      # jack (1024 buffer size (period), 2 periods/buffer (nperiods)) + pipewire?, cantata + mpd
      # syncthing
      # udevmon or whatever for Caps -> Esc
      # texlive-core, texlive-most, texlive, auctex -- LaTeX stuff
      # libreoffice
      # sonarr, radarr, rtorrent + rutorrent (infinisil recommends transmission)
      # strace
      # borg-backup (maybe restic? but it doesn't have compression yet)
      # ccls
      # wireguard
      # qemu + libvirt + ovmf + virt-manager (vfio)
      # procps-ng for pgrep and ps
      # lsof
    ];

    activation = with lib; {
      # Some software requires fonts to be present in $XDG_DATA_HOME/fonts in
      # order to use/see them (like Emacs), so just link to them.
      setupFonts = hm.dag.entryAfter [ "linkGeneration" ] ''
        fontsdir="${config.home.profileDirectory}/share/fonts"
        userfontsdir="${config.xdg.dataHome}/fonts"

        # remove dead symlinks due to uninstalled font (e.g. all opentype fonts
        # are gone, leading to a broken link), etc.
        $DRY_RUN_CMD find $userfontsdir -xtype l \
          -exec echo unlinking {} \; -exec unlink {} \;

        # force necessary because of the many different fonts in colliding
        # directories
        for dir in $fontsdir/*
        do
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
      ANDROID_HOME = "/opt/android-sdk";
      DEVKITPRO = "/opt/devkitpro";
      DEVKITARM = "${DEVKITPRO}/devkitARM";
      DEVKITPPC = "${DEVKITPRO}/devkitPPC";

      # Use all processors :)
      MAKEFLAGS = "$MAKEFLAGS\${MAKEFLAGS:+ }-j$(nproc)";

      # TODO: used for aurutils, unnecessary after move to NixOS
      AUR_PAGER = "ranger";

      # Solves locale issues on non-NixOS
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";

      # TODO: make config reproducible by cutting out NIX_PATH
      # (see: https://github.com/lovesegfault/nix-config/)
      # Add local conf and local nixpkgs to NIX_PATH
      NIX_PATH = lib.concatStringsSep ":" [
        "vin=${toString ./.}"
        "nixpkgs=${toString ~/workspace/vcs/nixpkgs}"
      ];

      # TODO: "Fontconfig error: Cannot load config file from /etc/fonts/fonts.conf"
      # Probably related to not being NixOS
      # FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";

      # FONTCONFIG_FILE = if fonts.fontconfig.enable then
      #   "${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
      # else
      #   "/etc/fonts/fonts.conf";
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "19.09";
  };

  services.lorri.enable = true;

  systemd.user = {
    services.lorri.Service.Environment = with lib;
      let
        path = with pkgs; makeSearchPath "bin" [ nix gitMinimal gnutar gzip ];
        # lorri complains about no nixpkgs because NIX_PATH is unset for it
      in mkForce [
        "PATH=${path}"
        "NIX_PATH=${config.home.sessionVariables.NIX_PATH}"
      ];

    systemctlPath = "/usr/bin/systemctl";
  };
}
