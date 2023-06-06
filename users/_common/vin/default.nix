{ inputs, config, lib, pkgs, ... }:

{
  imports =
    [
      ./modules
    ];

  home.username = "vin";
  # home.homeDirectory = "/home/vin";

  programs = {
    bash.enable = true;
    direnv.enable = true;
    home-manager.enable = true; # TODO: remove?
    zoxide.enable = true; # https://www.youtube.com/watch?v=Oyg5iFddsJI

    fzf = {
      enable = true;
      defaultCommand = "fd --type file --follow"; # FZF_DEFAULT_COMMAND
      defaultOptions = [ "--height 20%" ]; # FZF_DEFAULT_OPTS
      fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
    };
  };

  xdg.enable = true;

  home = {
    enableDebugInfo = true;
    extraOutputsToInstall = [ "man" ];

    # TODO: update skhd in nixpkgs
    packages = with pkgs;
      [
        # calibre # ebook manager
        dfmt # par + fmt but better
        # (dwarf-fortress-packages.dwarf-fortress-full.override { enableSound = false; enableFPS = true; })
        # foliate
        git-absorb
        jq # json fiddling
        libnotify # notifications part 2: electric boogaloo
        obsidian # notes zettelkasten type thing
        # TODO: still necessary?
        rustup
        vault
        # xivlauncher
        yt-dlp # youtube-dl but better
        zellij # better than tmux
      ];

    # NOTE: if you log in from a tty, make sure to erase __HM_SESS_VARS_SOURCED,
    # otherwise sessionVariables won't be sourced in new shells
    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";

      CARGO_HOME = "${config.home.homeDirectory}/.cargo";

      _ZO_FZF_OPTS="--no-sort --reverse --border --height 40%"; # zoxide fzf options
      LS_COLORS="ow=36:di=1;34;40:fi=32:ex=31:ln=35:";

      # I only want NIX_PATH available for my user, not for the entire system.
      NIX_PATH = builtins.concatStringsSep ":" [
        "nixpkgs=${inputs.self}/compat"
        "nixos-config=${inputs.self}/compat/nixos"
      ];
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
