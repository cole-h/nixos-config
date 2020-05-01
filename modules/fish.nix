{ config, lib, pkgs, ... }:
let
  cgitcAbbrs = (pkgs.callPackage ../drvs/fish/cgitc.nix { }).abbrs;
in
{
  home.packages = with pkgs; [
    # https://www.youtube.com/watch?v=Oyg5iFddsJI
    zoxide # z-rs; [overlays]
  ];

  programs = {
    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type file --follow"; # FZF_DEFAULT_COMMAND
      defaultOptions = [ "--height 20%" ]; # FZF_DEFAULT_OPTS
      fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
    };

    fish = {
      enable = true;

      plugins = with pkgs; [
        # {
        #   # allows nix and home-manager to work properly on expatriate systems (kept as a backup)
        #   name = "nix-env.fish";
        #   src = fetchFromGitHub {
        #     owner = "lilyball";
        #     repo = "nix-env.fish";
        #     rev = "cf99a2e6e8f4ba864e70cf286f609d2cd7645263";
        #     sha256 = "0170c7yy6givwd0nylqkdj7kds828a79jkw77qwi4zzvbby4yf51";
        #   };
        # }
        {
          # simple prompt
          name = "pure";
          src = fetchFromGitHub {
            owner = "rafaelrinaldi";
            repo = "pure";
            rev = "d66aa7f0fec5555144d29faec34a4e7eff7af32b";
            sha256 = "0klcwlgsn6nr711syshrdqgjy8yd3m9kxakfzv94jvcnayl0h62w";
          };
        }
      ];

      functions = {
        __fish_command_not_found_handler = {
          body = "__fish_default_command_not_found_handler $argv[1]";
          onEvent = "fish_command_not_found";
        };

        emacs_start_daemon = ''
          emacsclient --no-wait --eval '(ignore)' 2>/dev/null >/dev/null \
              || emacs --bg-daemon 2>/dev/null >/dev/null &

          # for some reason, starting the daemon can "error" (but still starts
          # Emacs), so reset the exit code
          true
        '';

        cprmusic = "mpv http://playerservices.streamtheworld.com/pls/KXPR.pls";
        # emacs = "env GDK_BACKEND=x11 emacs $argv";
        mpv = "command mpv --player-operation-mode=pseudo-gui $argv";
        nix-locate = "command nix-locate --top-level $argv";
        ssh = "env TERM=xterm-256color ssh $argv";
        std = "rustup doc --std";
        t = "todo.sh $argv";
        win10 = "doas virsh start windows10";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        "......" = "cd ../../../../..";
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
        weechat = "tmux -L weechat attach";
      } // cgitcAbbrs;

      loginShellInit = ''

        # tmux counts as a login shell
        if [ -z $TMUX ]
          # If terminal is login, unset __HM_SESS_VARS_SOURCED, because the
          # graphical session will inherit this (which means child applications
          # will never re-source when necessary)
          set -e __HM_SESS_VARS_SOURCED

          # Start sway
          if [ (tty) = "/dev/tty1" ]
            if [ (systemctl --user is-active sway.service) != "active" ]
              systemctl --user unset-environment SWAYSOCK I3SOCK WAYLAND_DISPLAY DISPLAY \
                        IN_NIX_SHELL __HM_SESS_VARS_SOURCED GPG_TTY
              systemctl --user import-environment
              exec systemctl --user --wait start sway.service
            end
          end

          # Start windows VM
          if [ (tty) = "/dev/tty5" ]
            exec doas virsh start windows10
          end

          set --global pure_symbol_prompt "\$"
          exit
        end
      '';

      shellInit = ''

        # Set PATH without actually modifying PATH
        set --global --append fish_user_paths $CARGO_HOME/bin $DEVKITPRO/tools/bin $HOME/.local/bin/ $GOPATH/bin
      '';

      promptInit = ''

        # Deactivate the default virtualenv prompt so that we can add our own
        set --global --export VIRTUAL_ENV_DISABLE_PROMPT 1

        # Whether or not is a fresh session
        set --global _pure_fresh_session true

        # Register `_pure_prompt_new_line` as an event handler for `fish_prompt`
        functions -q _pure_prompt_new_line

        set --global pure_color_success (set_color green)

        set -l nix_shell_info (
          if string match -q -- "lorri*" $name
            printf "lorri "
          else if test -n "$IN_NIX_SHELL"
            printf "nix-shell "
          end

          echo '$'
          # echo "λ"
        )

        set --global pure_symbol_prompt "$nix_shell_info"
      '';

      interactiveShellInit = ''

        # GPG configuration
        set --global --export PINENTRY_USER_DATA gtk # nonstandard -- used by my pinentry script
        set --global --export GPG_TTY (tty)
        # ''${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye >/dev/null &

        # Rust stuff
        if command -q rustc
          set --global --export --prepend LD_LIBRARY_PATH (rustc +nightly --print sysroot)"/lib"
          set --global --export RUST_SRC_PATH (rustc --print sysroot)"/lib/rustlib/src/rust/src"
        end

        # Miscellaneous exports
        set --global --export SKIM_DEFAULT_COMMAND 'fd --type f || git ls-tree -r --name-only HEAD || rg --files || find .'
        set --global --export SKIM_DEFAULT_OPTIONS '--height 20%'
        set --global --export LS_COLORS 'ow=36:di=1;34;40:fi=32:ex=31:ln=35:'

        eval (${pkgs.direnv}/bin/direnv hook fish)
        ${pkgs.zoxide}/bin/zoxide init fish --hook pwd | source

        emacs_start_daemon &
        t ls
        printf '\n'
      '';
    };
  };
}
