{ config, lib, pkgs, my, ... }:
let
  cgitcAbbrs = (pkgs.callPackage my.drvs.cgitc { }).abbrs;
in
{
  home.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";

  programs = {
    direnv.enable = true;

    # https://www.youtube.com/watch?v=Oyg5iFddsJI
    zoxide.enable = true;

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type file --follow"; # FZF_DEFAULT_COMMAND
      defaultOptions = [ "--height 20%" ]; # FZF_DEFAULT_OPTS
      fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
    };

    fish = {
      enable = true;

      functions = {
        cprmusic = "mpv http://playerservices.streamtheworld.com/pls/KXPR.pls";
        mpv = "command mpv --player-operation-mode=pseudo-gui $argv";
        nix-locate = "command nix-locate --top-level $argv";
        ssh = "env TERM=xterm-256color ssh $argv";
        # std = "rustup doc --std";
        t = "todo.sh $argv";
        win10 = "doas virsh start windows10";
        fish_greeting = "";
        fish_user_key_bindings = "bind \\cw backward-kill-word";
      };

      shellAbbrs = {
        l = "exa";
        la = "exa -la";
        ll = "exa -l";
        ls = "exa";
        tree = "exa -T";
        vim = "nvim";
        vi = "nvim";
        "cd.." = "cd ..";
        "..." = "../..";
        "...." = "../../..";
        "....." = "../../../..";
        "......" = "../../../../..";
        "......." = "../../../../../..";
        weechat = "tmux -L weechat attach";
      } // cgitcAbbrs;

      loginShellInit = ''

        # tmux counts as a login shell
        if [ -z $TMUX ]
          # If terminal is login, unset __HM_SESS_VARS_SOURCED, because the
          # graphical session will inherit this (which means child applications
          # will never re-source when necessary)
          set -e __HM_SESS_VARS_SOURCED

          # Start windows VM
          if [ (tty) = "/dev/tty5" ]
            exec doas virsh start windows10
          end

          exit
        end
      '';

      interactiveShellInit = ''

        set --append fish_user_paths $HOME/.cargo/bin

        # For zoxide's fzf window
        set --global --export _ZO_FZF_OPTS '--no-sort --reverse --border --height 40%'

        # Miscellaneous exports
        set --global --export LS_COLORS 'ow=36:di=1;34;40:fi=32:ex=31:ln=35:'

        t ls
        printf '\n'
      '';
    };
  };
}
