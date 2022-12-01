{ config, lib, pkgs, my, ... }:
let
  cgitcAbbrs = (pkgs.callPackage my.drvs.cgitc { }).abbrs;
in
{
  programs = {
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

        # https://github.com/jorgebucaran/humantime.fish/blob/53b2adb4c6aff0da569c931a3cc006efcd0e7219/functions/humantime.fish
        # TODO: run this on $CMD_DURATION in prompt
        humantime = {
          argumentNames = [ "ms" ];
          description = "Turn milliseconds into a human-readable string";
          body = ''
            set --query ms[1] || return

            set --local secs (math --scale=1 $ms/1000 % 60)
            set --local mins (math --scale=0 $ms/60000 % 60)
            set --local hours (math --scale=0 $ms/3600000)

            test $hours -gt 0 && set --local --append out $hours"h"
            test $mins -gt 0 && set --local --append out $mins"m"
            test $secs -gt 0 && set --local --append out $secs"s"

            set --query out && echo $out || echo $ms"ms"
          '';
        };
      };

      shellAbbrs = {
        l = "exa";
        la = "exa -la";
        ll = "exa -l";
        ls = "exa";
        tree = "exa -T";
        "cd.." = "cd ..";
        "..." = "../..";
        "...." = "../../..";
        "....." = "../../../..";
        "......" = "../../../../..";
        "......." = "../../../../../..";
      } // cgitcAbbrs;

      interactiveShellInit = ''

        set --append fish_user_paths $HOME/.cargo/bin

        # For zoxide's fzf window
        set --global --export _ZO_FZF_OPTS '--no-sort --reverse --border --height 40%'

        # Miscellaneous exports
        set --global --export LS_COLORS 'ow=36:di=1;34;40:fi=32:ex=31:ln=35:'

        # t ls
        # printf '\n'
      '';
    };
  };
}
