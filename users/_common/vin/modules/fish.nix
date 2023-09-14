{ config, lib, pkgs, ... }:
let
  cgitcAbbrs = pkgs.cgitc.abbrs;
in
{
  programs = {
    fish = {
      enable = true;

      functions = {
        cprmusic = "mpv http://playerservices.streamtheworld.com/pls/KXPR.pls";
        mpv = "command mpv --player-operation-mode=pseudo-gui $argv";
        nix-locate = "command nix-locate --top-level $argv";
        which = "realpath (command which $argv)";
        ssh = "env TERM=xterm-256color ssh $argv";
        # std = "rustup doc --std";
        fish_greeting = "";
        fish_user_key_bindings = "bind \\cw backward-kill-word";

        # https://github.com/jorgebucaran/humantime.fish/blob/53b2adb4c6aff0da569c931a3cc006efcd0e7219/functions/humantime.fish
        humantime = {
          argumentNames = [ "ms" ];
          description = "Turn milliseconds into a human-readable string";
          body = ''
            set --query ms[1] || return

            set --local secs (math --scale=1 $ms/1000 % 60)
            set --local mins (math --scale=0 $ms/60000 % 60)
            set --local hours (math --scale=0 $ms/3600000)

            test $hours -gt 0 && set --local --append __out $hours"h"
            test $mins -gt 0 && set --local --append __out $mins"m"
            test $secs -gt 0 && set --local --append __out $secs"s"

            if set --query __out
                string replace --all " " "" $__out || :
            else
                echo $ms"ms"
            end
          '';
        };

        fish_prompt = {
          description = "Write out the prompt";
          body = ''
              set -l last_pipestatus $pipestatus
              set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
              set -l normal (set_color normal)
              set -q fish_color_status
              or set -g fish_color_status red

              # Color the prompt differently when we're root
              set -l color_cwd $fish_color_cwd
              set -l suffix '>'
              if functions -q fish_is_root_user; and fish_is_root_user
                  if set -q fish_color_cwd_root
                      set color_cwd $fish_color_cwd_root
                  end
                  set suffix '#'
              end

              # Write pipestatus
              # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
              set -l bold_flag --bold
              set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
              if test $__fish_prompt_status_generation = $status_generation
                  set bold_flag
              end
              set __fish_prompt_status_generation $status_generation
              set -l status_color (set_color $fish_color_status)
              set -l statusb_color (set_color $bold_flag $fish_color_status)
              set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)
              set -l last_command_time (humantime $CMD_DURATION)

              test "$__ksi_prompt_state" != prompt-start
              and printf "\e]133;D\a"
              set --global __ksi_prompt_state prompt-start
              printf "\e]133;A\a"
              printf "\e]133;P\a"
              echo -n -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status " "$last_command_time $suffix " "
              printf "\e]133;B\a"
          '';
        };
      };

      shellAbbrs = {
        l = "eza";
        la = "eza -la";
        ll = "eza -l";
        ls = "eza";
        tree = "eza -T";
        "cd.." = "cd ..";
        "..." = "../..";
        "...." = "../../..";
        "....." = "../../../..";
        "......" = "../../../../..";
        "......." = "../../../../../..";
      } // cgitcAbbrs;

      interactiveShellInit = ''
        set --append fish_user_paths $HOME/.cargo/bin

        # wezterm integration
        if not set -q __ksi_prompt_state
          function __ksi_mark_output_start --on-event fish_preexec
              set --global __ksi_prompt_state pre-exec
              printf "\e]133;C\a"
          end

          function __ksi_mark_output_end --on-event fish_postexec
              set --global __ksi_prompt_state post-exec
              printf "\e]133;D;$status\a"
          end
        end
      '';
    };
  };
}
