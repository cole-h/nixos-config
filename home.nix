{ config, lib, pkgs, ... }:

{
  imports = [ ./modules ];

  programs = {
    home-manager = {
      enable = true;
      path = "${config.home.homeDirectory}/workspace/vcs/home-manager";
    };
  };

  xdg.enable = true;

  home = {
    extraOutputsToInstall = [ "man" ];

    # TODO: a lot of these should go in system packages once I switch to NixOS
    packages = with pkgs; [
      ## nix-related
      cachix
      direnv
      niv
      nix # adds nix.sh to .nix-profile/etc/profile.d, which sets path stuff,
          # which allows us to use binaries
      nixfmt # [overlays]
      nix-index
      nixpkgs-fmt
      nix-top
      nox

      # glibcLocales # to deal with locale issues on non-NixOS

      ## system-related
      # musl

      ## shell-related
      fish
      fzf

      ## tools
      exa
      ripgrep # [overlays]
      fd
      bat
      skim
      tokei
      ytop
      ffsend
      qimgv

      # TODO: go through fish history and make a note of binaries
      #   general purpose binaries (like above) should probably go into system packages

      #### TODO: most of these become system packages on NixOS
      # curl
      # coreutils
      # evince
      # gdb
      # lldb
      # htop
      # need cups for printing, etc.; gutenprint + canon-pixma-m920-complete (aur)
      # need ntfs-3g + fuse for mounting NTFS
      # libguestfs, libguestfs-tools, libiscis -- for vfio iSCSI
      # android stuff (probably just a lorri/nix-shell env)
      # jack (1024 buffer size (period), 2 periods/buffer (nperiods)) + pipewire, cantata + mpd
      # syncthing
      # texlive-core, texlive-most, texlive, auctex -- LaTeX stuff
      # libreoffice
      # sonarr, radarr, rtorrent + rutorrent (or deluge, or qbittorrent...)
      # strace
      # borg-backup (maybe restic? but it doesn't have compression yet)
      # ccls
      # wireguard
      # qemu + libvirt + ovmf + virt-manager (vfio)
      # procps-ng for pgrep and ps

      # lsof

      ## misc
      chatterino2 # Twitch chat client [drvs]
    ];

    activation = with lib; {
      # Some software requires fonts to be present in $XDG_DATA_HOME/fonts in
      # order to use/see them (like Emacs), so we just link to them.
      setupFonts = hm.dag.entryAfter [ "writeBoundary" ] ''
        fontsdir="${config.home.homeDirectory}/.nix-profile/share/fonts"

        # force necessary because of the many different fonts in colliding
        # directories
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
            $fontsdir/* ${config.xdg.dataHome}/fonts
      '';
    };

    # NOTE: if you log in from a tty, make sure to erase __HM_SESS_VARS_SOURCED,
    # otherwise the new sessionVariables won't be sourced in new shells
    sessionVariables = {
      # solve locale issues on non-NixOS
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";

      # Add local conf and local nixpkgs to NIX_PATH
      # This deduplicates disk space (why use a channel when I have a local repo
      #   -- waste of bandwidth and disk space)
      NIX_PATH =
        "vin=${toString ./.}:nixpkgs=${toString ~/workspace/vcs/nixpkgs}";

      # FIXME: "Fontconfig error: Cannot load config file from /etc/fonts/fonts.conf"
      # Probably related to not being NixOS
      FONTCONFIG_FILE = if config.fonts.fontconfig.enable then
        "${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
      else
        "/etc/fonts/fonts.conf";

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
        "NIX_PATH=nixpkgs=${config.home.homeDirectory}/workspace/vcs/nixpkgs:vin=${config.xdg.configHome}/nixpkgs"
      ];

    systemctlPath = "/usr/bin/systemctl";
  };
}
