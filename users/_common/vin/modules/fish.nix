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
        sshno = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $argv";
        # std = "rustup doc --std";
        fish_greeting = "";
        jj = {
          body = ''
            set -l TMPDIR /tmp/jj
            test -e $TMPDIR || mkdir -p $TMPDIR
            command jj $argv
          '';
        };

        maybe_fg_or_exec = {
          description = "If the command you're about to run is backgrounded, foreground it instead of starting a new one";
          body = ''
            set -l cmd (commandline -b)

            for line in (jobs)
                set -l trimmed (string trim "$line")
                set trimmed (string replace -a \t " " "$trimmed")
                set -l parts (string split " " "$trimmed")
                set -l job_id "$parts[1]"
                set -l cmdline "$parts[5..-1]"

                test -z "$cmdline" && continue

                if test "$cmdline" = "$cmd"
                    commandline -r "fg %$job_id"
                    commandline -f execute
                    return
                end
            end

            commandline -f execute
          '';
        };

        fish_user_key_bindings = {
          body = ''
            bind \\cw backward-kill-word
            bind enter maybe_fg_or_exec
          '';
        };

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

        fish_jj_prompt = {
          description = "Write out the jj prompt";
          body = ''
            # Is jj installed?
            if not command -sq jj
                return 1
            end

            # Are we in a jj repo?
            if not jj root &>/dev/null
                return 1
            end

            # Generate prompt
            set -l info "$(
                set -l op_id (jj op log --ignore-working-copy --no-graph --limit=1 --template 'self.id().short()')
                jj log --ignore-working-copy --no-graph --color=always --revisions=@ --template "
                    separate(
                        ' ',
                        label('operation id', '$op_id'),
                        bookmarks.join(', '),
                        if(conflict, label('conflict', '×')),
                        if(empty, label('empty', '(empty)')),
                        if(divergent, label('divergent', '(divergent)')),
                        if(hidden, label('hidden', '(hidden)')),
                    )
                "
            )"
            or return 1

            if test -n $info
                printf ' (%s)' $info
            else
                return 1
            end
          '';
        };

        fish_prompt = {
          description = "Write out the prompt";
          body = ''
              set -l last_pipestatus $pipestatus
              set -lx __fish_last_status $status # Export for __fish_print_pipestatus.

              set -l last_cmd "$history[1]"
              set -l last_exe (string split ' ' -- $last_cmd)[1]

              # NOTE: jj exits with code 3[1] when e.g. its pager sees a SIGPIPE (i.e. when it exits before
              # consuming the entire pipe). However, when e.g. git's pager sees a SIGPIPE, it exits with that
              # signal (at some point...?), and fish will reinterpret it as status 141 (128 + signal 13 for
              # SIGPIPE) and then ignore it in `__fish_print_pipestatus`[2], since SIGPIPE is usually not an
              # error. Blanket ignoring an exit code of 3 is probably a bad idea (since it's not a
              # standardized exit code), so let's follow what git does and fake the status to 141.
              # 
              # [1]: https://github.com/jj-vcs/jj/blob/ffad6fe96f1c6415715f9aa58e3764f4a3429af2/cli/src/command_error.rs#L893
              # [2]: https://github.com/fish-shell/fish-shell/blob/360cfdb7ae7af9a73cc3f357a78bd35b5b12e829/share/functions/__fish_print_pipestatus.fish#L22-L24
              if test "$last_exe" = jj; and test "$__fish_last_status" = 3
                  # 128 + SIGPIPE (13)
                  set last_pipestatus 141
                  set __fish_last_status 141
              end

              set -l normal (set_color normal)
              set -q fish_color_status
              or set -g fish_color_status red

              # Color the prompt differently when we're root
              set -l color_cwd $fish_color_cwd
              set -l suffix ';:'
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
              set -l cur_date (date '+%H:%M:%S %d %b %Y')

              test "$__ksi_prompt_state" != prompt-start
              and printf "\e]133;D\a"
              set --global __ksi_prompt_state prompt-start
              printf "\e]133;A\a"
              printf "\e]133;P\a"
              echo -e -n -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status " "(set_color cyan)$cur_date $normal " "$last_command_time "\n" $suffix " "
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

        if command -sq jj
          COMPLETE=fish jj | source
        end

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
