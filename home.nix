{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules
    ./options.nix
  ];

  home.username = "${builtins.getEnv "USER"}";
  home.homeDirectory = "${builtins.getEnv "HOME"}";

  programs.home-manager = {
    enable = true;
    path = "${config.home.homeDirectory}/workspace/vcs/home-manager";
  };

  services = {
    syncthing.enable = true;
    lorri.enable = true;
  };

  xdg.enable = true;

  # Finally, a cursor theme that displays hands on clickable objects
  home.file.".icons/default".source = "${pkgs.gnome3.adwaita-icon-theme}/share/icons/Adwaita";
  xsession.pointerCursor = {
    package = pkgs.gnome3.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  home = {
    enableDebugInfo = true;
    extraOutputsToInstall = [ "man" ];

    packages = with pkgs; [
      ## nix-related
      cachix
      direnv
      niv
      nix-index
      nixops
      nixpkgs-fmt
      nix-prefetch
      nix-prefetch-scripts
      nix-top

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
      aerc # terminal email reader; TODO: add config to secrets/
      tmate # "Instant Terminal Sharing"
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
      todo-txt-cli # todos tracker

      #### User Packages
      # go # maybe
      evince
      zathura
      pavucontrol
      gitAndTools.hub
      ncdu
      gnome3.networkmanagerapplet
      gnome3.nautilus # GUI file manager
      gnome3.file-roller
      foliate
      filezilla
      # ccls # C lsp server
      # binwalk

      #### System Packages
      # openconnect # for school VPN, if needed
      # wireguard # (wg, wg-quick

      ## haskell stuff
      ## Switch USB stuff
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
