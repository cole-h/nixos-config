{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules
    ./options.nix
  ];

  programs.home-manager = {
    enable = true;
    path = "${config.home.homeDirectory}/workspace/vcs/home-manager";
  };

  services = {
    syncthing.enable = true;
    lorri.enable = true;
  };

  xdg.enable = true;

  # Finally, a cursor theme that has hands on clickables
  home.file.".icons/default".source = "${pkgs.gnome3.adwaita-icon-theme}/share/icons/Adwaita";
  xsession.pointerCursor = {
    package = pkgs.gnome3.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

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
      nix-prefetch
      nix-top
      lorri

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
      hexyl # hex viewer
      hyperfine # cli benchmarker
      aerc # terminal email reader (why tf does it bring emacs into its closure????)
      tmate # "Instant Terminal Sharing" -- for debugging darwin issues via GH Actions
      libreoffice

      latest.firefox-beta-bin
      # latest.firefox-nightly-bin
      pass-otp
      passrs
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
      pavucontrol
      # gitAndTools.hub
      # ncdu
      # rust-analyzer # (ra_lsp_server
      # lldb
      gnome3.networkmanagerapplet
      gnome3.nautilus # GUI file manager
      gnome3.file-roller
      foliate
      filezilla
      # texlive.combined.scheme-medium # texlive-core, texlive-most, texlive, auctex -- LaTeX stuff
      # ccls # C lsp server
      # binwalk

      #### System Packages
      # borgbackup # (borg)
      # openconnect # for school VPN, if needed
      # wireguard # (wg, wg-quick

      ## haskell stuff
      ## Switch USB stuff
      ## syncthing service
      ## sonarr, radarr, rtorrent + rutorrent (infinisil recommends transmission)
      ## udevmon or whatever for Caps -> Esc (or buy the Drop CTRL lol)

      ## qemu + libvirt + ovmf + virt-manager (vfio) + libvirt hooks
      ## VM shit
      # bridge_utils # maybe unnecssary?
      # cryptsetup
      # ntfs3g
      # libguestfs # (guestmount,
    ];

    # NOTE: if you log in from a tty, make sure to erase __HM_SESS_VARS_SOURCED,
    # otherwise sessionVariables won't be sourced in new shells
    sessionVariables = rec {
      EDITOR = "nvim";
      VISUAL = EDITOR;

      # Path-related exports
      # GOPATH = "${config.home.homeDirectory}/.go";
      CARGO_HOME = "${config.home.homeDirectory}/.cargo";
      # ANDROID_HOME = "${pkgs.androidenv.androidPks_9_0.androidsdk}/libexec/android-sdk";
      # DEVKITPRO = "/opt/devkitpro";
      # DEVKITARM = "${DEVKITPRO}/devkitARM";
      # DEVKITPPC = "${DEVKITPRO}/devkitPPC";

      # Use all processors :)
      MAKEFLAGS = "\${MAKEFLAGS:+$MAKEFLAGS }-j$(nproc)";

      # TODO: make config reproducible by cutting out NIX_PATH
      # (see: https://github.com/lovesegfault/nix-config/)
      # maybe investigate flakes
      # (see: https://github.com/nrdxp/nixflk/)

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
    stateVersion = "20.09";
  };
}
