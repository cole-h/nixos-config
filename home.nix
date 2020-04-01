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
      nix-top

      ## system-related
      # musl

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
      # broot # tree cd'er thing

      # latest.firefox-beta-bin
      latest.firefox-nightly-bin
      pass
      passff-host
      android-studio # android apps

      newsboat # rss/atom feed reader

      ## misc
      chatterino2 # Twitch chat client; [drvs]
      discord
      # (
      #   runCommand "discord" { buildInputs = [ makeWrapper ]; } ''
      #     mkdir -p $out/bin
      #     makeWrapper ${discord}/bin/Discord $out/bin/discord \
      #       --set "GDK_BACKEND" "x11"
      #     # ln -s ''${discord}/bin/Discord $out/bin/discord
      #   ''
      # )

      #### TODO: most of these become system packages on NixOS
      # hexdump
      # ffprobe
      # bash, zsh, gcc (use via nix-shell), dirname, todo.txt (todo.sh)
      # killall, nc, tail, gdb, go (use via nix-shell)
      # xdg-mime, file, tput, lp{stat,admin,...}, cups*
      # evince, zathura, objdump, strip, watch, stat, {p,}kill, ps aux
      # strace, pulaseaudio, dkms?, python (black), firewalld (or ufw)
      # df, lsblk, umount, aplay, awk, bc, binwalk, blockdev, bootctl
      # borgbackup, brctl, bsdtar, cadence, chattr, cfdisk, chmod, chown
      # convert/mogrify (imagemagick), dig, file-roller, find, firefox, firejail,
      # fontforge, gcc, haskell stuff, getcap, getenf, getfacl, getfattr
      # gpg-error (libgpgerror), head, hub (github cli), inxi, iotop, ip
      # LATEX STUFF!!!, ldd, less, libreoffice, ln, locale, lsmod, {sha256,md5,...}sum
      # mpc, nautilus, ncdu, neofetch, nm-connection-editor, obs studio, openconnect, openssl
      # pactl, pgrep, pidof, ping, pkill, qemu, FIXME: ra_lsp_server, ranger, readlink/realpath
      # reptyr, sed, seq, showkey, shred, openssh, stow?, streamlink, syncthinc, tracepath
      # wireguard, wine?, youtube-dl

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
      DEVKITPRO = "/opt/devkitpro";
      DEVKITARM = "${DEVKITPRO}/devkitARM";
      DEVKITPPC = "${DEVKITPRO}/devkitPPC";

      # Use all processors :)
      MAKEFLAGS = "\${MAKEFLAGS:+$MAKEFLAGS }-j$(nproc)";

      # Solves locale issues on non-NixOS
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";

      # Add local conf and local nixpkgs to NIX_PATH
      # TODO: make config reproducible by cutting out NIX_PATH
      # (see: https://github.com/lovesegfault/nix-config/)
      # maybe investigate flakes
      # (see: https://github.com/nrdxp/nixflk/)
      NIX_PATH = lib.concatStringsSep ":" [
        "vin=${toString ./.}"
        "nixpkgs=${toString ~/workspace/vcs/nixpkgs}"
      ];

      # Otherwise, apps that rely on this being set (*cough* wrapped GApps *cough*) will function
      # improperly
      # TODO: package rofi-emoji properly and drop this
      XDG_DATA_DIRS = lib.concatStringsSep ":" [
        "/usr/share"
        "/usr/local/share"
        "/nix/var/nix/profiles/default/share"
        "$HOME/.nix-profile/share"
      ] + "\${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}";
    };

    # The host operating system that Home Manager will be installed
    # on. This enables OS-specific workarounds and tweaks to increase
    # the general cohesiveness of the system.
    # For a list of supported systems, see `man home-configuration.nix`.
    targetOperatingSystem = "linux";

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
