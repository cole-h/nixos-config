{ inputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ./modules
    ];

  home.username = "vin";
  home.homeDirectory = "/home/vin";

  programs.home-manager.enable = true;
  programs.bash.enable = true;

  services = {
    syncthing.enable = true;
    lorri.enable = true;
  };

  xdg.enable = true;

  home.file."scripts".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/scripts";
  home.file."Music".source =
    config.lib.file.mkOutOfStoreSymlink "/shares/media/Music";

  # Finally, a cursor theme that displays hands on clickable objects
  xsession.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  home = {
    enableDebugInfo = true;
    extraOutputsToInstall = [ "man" ];

    packages = with pkgs;
      [
        aerc # terminal email reader; TODO: add config to secrets/
        amfora # gemini:// browser
        # android-studio # android apps
        bootloadHID # used to flash my QMK numpad
        chatterino2 # Twitch chat client
        dfmt # par + fmt but better
        discord
        # (dwarf-fortress-packages.dwarf-fortress-full.override { enableSound = false; enableFPS = true; })
        firefox-bin
        foliate
        mdloader # used to flash my Drop CTRL
        newsboat # rss/atom feed reader
        qimgv # image viewer
        thunderbird
        todo-txt-cli # todos tracker
        calibre # ebook manager

        element-desktop
        git-absorb
        screen
        _1password
        _1password-gui
        vault
        (vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions; [
            ms-vsliveshare.vsliveshare
            matklad.rust-analyzer
            hashicorp.terraform
            golang.go
            eamodio.gitlens
            bbenoist.nix
            stkb.rewrap
            usernamehw.errorlens
            editorconfig.editorconfig
          ];
        })
      ];

    # NOTE: if you log in from a tty, make sure to erase __HM_SESS_VARS_SOURCED,
    # otherwise sessionVariables won't be sourced in new shells
    sessionVariables = {
      EDITOR = "kak";
      VISUAL = "kak";

      CARGO_HOME = "${config.home.homeDirectory}/.cargo";

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
