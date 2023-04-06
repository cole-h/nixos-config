{ inputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ./modules
    ];

  home.username = "vin";
  home.homeDirectory = "/home/vin";

  programs = {
    # atuin.enable = true;
    bash.enable = true;
    direnv.enable = true;
    home-manager.enable = true; # TODO: remove?
    # starship.enable = true;
    zoxide.enable = true; # https://www.youtube.com/watch?v=Oyg5iFddsJI

    fzf = {
      enable = true;
      defaultCommand = "fd --type file --follow"; # FZF_DEFAULT_COMMAND
      defaultOptions = [ "--height 20%" ]; # FZF_DEFAULT_OPTS
      fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
    };
  };

  services.syncthing.enable = true;

  xdg.enable = true;

  home.file."scripts".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/flake/scripts";
  home.file."Music".source =
    config.lib.file.mkOutOfStoreSymlink "/shares/media/Music";

  # Finally, a cursor theme that displays hands on clickable objects
  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  home = {
    enableDebugInfo = true;
    extraOutputsToInstall = [ "man" ];

    packages = with pkgs;
      [
        _1password
        _1password-gui
        # calibre # ebook manager
        chatterino2 # Twitch chat client
        colmena # deployment
        dfmt # par + fmt but better
        discord
        # (dwarf-fortress-packages.dwarf-fortress-full.override { enableSound = false; enableFPS = true; })
        element-desktop
        firefox-bin
        # foliate
        git-absorb
        obsidian # notes zettelkasten type thing
        qimgv # image viewer
        rust-analyzer
        rustup
        todo-txt-cli # todos tracker
        vault
        # xivlauncher
        zellij # better than tmux

        (vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions; [
            ms-vsliveshare.vsliveshare
            rust-lang.rust-analyzer
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
      EDITOR = "hx";
      VISUAL = "hx";

      CARGO_HOME = "${config.home.homeDirectory}/.cargo";
      SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh"; # gnome-keyring

      _ZO_FZF_OPTS="--no-sort --reverse --border --height 40%"; # zoxide fzf options
      NIXOS_OZONE_WL = "1"; # enable Ozone Wayland for Electron apps
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
