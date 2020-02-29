{ config, lib, pkgs, ... }:

{
  imports = [ ./conf ];

  programs = {
    # only for non-NixOS -- otherwise complains about locale
    man.enable = false;

    home-manager = {
      enable = true;
      path = "$HOME/workspace/git/home-manager";
    };
  };

  # xdg.enable = true;

  home = {
    extraOutputsToInstall = [ "man" ];

    # TODO: a lot of these should go in system packages once I switch to NixOS
    packages = with pkgs; [
      ## nix-related
      cachix
      direnv
      niv
      nix # adds nix.sh to .nix-profile/etc/profile.d
      nixfmt
      nix-index
      nixpkgs-fmt
      nix-top
      nox

      glibcLocales # to deal with locale issues on non-NixOS

      ## system-related
      # musl

      ## shell-related
      fish
      fzf

      ## tools
      exa
      (ripgrep.override { withPCRE2 = true; })
      fd
      bat
      skim
      tokei
      ytop
      ffsend
      gitAndTools.delta # TODO: remove me when I enable the git conf

      # TODO: go through fish history and make a note of binaries
      #   general purpose binaries (like above) should probably go into system packages

      # evince
      # gdb
      # lldb
      # need cups for printing, etc.; gutenprint + canon-pixma-m920-complete (aur)
      # need ntfs-3g + fuse for mounting NTFS
      # TODO: package qimgv
      # libguestfs, libguestfs-tools, libiscis -- for vfio iSCSI
      # android stuff
      # pulseaudio + alsa + jack + cadence, cantata + mpd
      # syncthing
      # texlive-core, texlive-most, texlive, auctex -- LaTeX stuff
      # libreoffice
      # sonarr, radarr, rtorrent + rutorrent
      # strace
      # borg-backup (maybe restic? but it doesn't have compression yet)
      # ccls
      # wireguard
      # qemu + libvirt + ovmf + virt-manager (vfio)

      # lsof

      ## misc
      chatterino2 # Twitch chat client [overlays]
    ];

    activation = with lib; {
      # There is no automatic cleanup for user-defined activation scripts, so I
      # have to take care of that myself.
      cleanFonts = hm.dag.entryAfter [ "writeBoundary" ] ''
        fontsdir="$HOME/.nix-profile/share/fonts"

        for dirname in $fontsdir/*; do
          $DRY_RUN_CMD unlink ${config.xdg.dataHome}/fonts/$(basename $dirname) \
              || true
        done
      '';

      # Some software requires fonts to be present in $XDG_DATA_HOME/fonts in
      # order to use/see them (like Emacs), so we just link to them.
      setupFonts = hm.dag.entryAfter [ "cleanFonts" ] ''
        fontsdir="$HOME/.nix-profile/share/fonts"

        $DRY_RUN_CMD ln -s $VERBOSE_ARG \
            $fontsdir/* ${config.xdg.dataHome}/fonts
      '';
    };

    # NOTE: if you log in from a tty, make sure to erase __HM_SESS_VARS_SOURCED,
    # otherwise, when `home-manager switch`ing, the new sessionVariables won't
    # be sourced
    sessionVariables = {
      # solve locale issues on non-NixOS
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
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
        "NIX_PATH=${config.home.homeDirectory}/.nix-defexpr/channels"
      ];

    systemctlPath = "/usr/bin/systemctl";
  };
}
