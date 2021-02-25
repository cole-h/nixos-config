{ inputs, config, lib, pkgs, ... }:

{
  imports =
    [
      "${inputs.impermanence}/home-manager.nix"
      ./modules
    ];

  home.username = "vin";
  home.homeDirectory = "/home/vin";

  programs.home-manager.enable = true;

  services = {
    syncthing.enable = true;
    lorri.enable = true;
  };

  xdg.enable = true;

  home.file."scripts".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/scripts";
  home.file."Music".source =
    config.lib.file.mkOutOfStoreSymlink "/media/Music";

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

    packages = with pkgs;
      [
        ## tools
        aerc # terminal email reader; TODO: add config to secrets/
        hydrus # booru-like image tagger
        mdloader # used to flash my Drop CTRL
        newsboat # rss/atom feed reader
        amfora # gemini:// browser
        qimgv # image viewer
        bootloadHID # used to flash my QMK numpad
        firefox-bin
        pass-otp
        passrs
        # android-studio # android apps
        chatterino2 # Twitch chat client
        discord
        todo-txt-cli # todos tracker
        foliate
        # (dwarf-fortress-packages.dwarf-fortress-full.override { enableSound = false; enableFPS = true; })
        thunderbird
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
