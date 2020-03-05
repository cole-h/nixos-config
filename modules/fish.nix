{ config, lib, pkgs, ... }:

let cgitcAbbrs = (pkgs.callPackage ../drvs/fish/cgitc.nix { }).abbrs;
in {
  programs.fish = {
    enable = true;

    plugins = [
      {
        # allows nix and home-manager to work properly on expatriate systems
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "cf99a2e6e8f4ba864e70cf286f609d2cd7645263";
          sha256 = "0170c7yy6givwd0nylqkdj7kds828a79jkw77qwi4zzvbby4yf51";
        };
      }
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "rafaelrinaldi";
          repo = "pure";
          rev = "d66aa7f0fec5555144d29faec34a4e7eff7af32b";
          sha256 = "0klcwlgsn6nr711syshrdqgjy8yd3m9kxakfzv94jvcnayl0h62w";
        };
      }
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "ddeb28a7b6a1f0ec6dae40c636e5ca4908ad160a";
          sha256 = "0c5i7sdrsp0q3vbziqzdyqn4fmp235ax4mn4zslrswvn8g3fvdyh";
        };
      }
    ];

    functions = {
      __fish_command_not_found_handler = {
        body = "__fish_default_command_not_found_handler $argv[1]";
        onEvent = "fish_command_not_found";
      };
      emacs_start_daemon = ''
        emacsclient --no-wait --eval '(ignore)' >/dev/null 2>/dev/null \
            || env GDK_BACKEND=x11 emacs --bg-daemon >/dev/null 2>/dev/null &

        # for some reason, starting the daemon can "error" (but still starts
        # Emacs), so reset the exit code
        true
      '';
      emacs = "env GDK_BACKEND=x11 emacs $argv";
      nix-locate = "command nix-locate --top-level $argv";
      cprmusic = "mpv http://playerservices.streamtheworld.com/pls/KXPR.pls";
      mpv = "command mpv --player-operation-mode=pseudo-gui $argv";
      std = "rustup doc --std";
      t = "todo.sh $argv";
      win10 = "sudo virsh start windows10";
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
      vi = "nvim";
      vim = "nvim";
      weechat = "tmux -L weechat attach"; # TODO: nix-ify weechat installation
      # weechat = "screen -d -r weechat";
      "cd.." = "cd ..";
    } // cgitcAbbrs;

    shellInit = ''

      # Miscellaneous exports
      set --global --export EDITOR 'nvim'
      set --global --export VISUAL 'nvim'
      set --global --export AUR_PAGER 'ranger' # used for aurutils
      set --global --export FZF_DEFAULT_COMMAND 'fd --type file --follow'
      set --global --export FZF_CTRL_T_COMMAND 'fd --type file --follow'
      set --global --export FZF_DEFAULT_OPTS '--height 20%'
      set --global --export SKIM_DEFAULT_COMMAND 'fd --type f || git ls-tree -r --name-only HEAD || rg --files || find .'
      set --global --export SKIM_DEFAULT_OPTIONS '--height 20%'
      set --global --append MAKEFLAGS -j(nproc)
      set --global --export LS_COLORS 'ow=36:di=1;34;40:fi=32:ex=31:ln=35:'

      # Path-related exports
      set --global --export ANDROID_HOME /opt/android-sdk
      set --global --export GOPATH $HOME/.go
      set --global --export CARGO_HOME $HOME/.cargo
      set --global --export DEVKITPRO /opt/devkitpro
      set --global --export DEVKITARM $DEVKITPRO/devkitARM
      set --global --export DEVKITPPC $DEVKITPRO/devkitPPC

      # Set PATH without actually modifying PATH
      set --global --append fish_user_paths $CARGO_HOME/bin $DEVKITPRO/tools/bin $HOME/.local/bin/ $GOPATH/bin

      # Add local conf and local nixpkgs to NIX_PATH
      # This deduplicates disk space (why use a channel when I have a local repo
      #   -- waste of bandwidth and disk space)
      set --global --append NIX_PATH "vin=${toString ./..}" \
          "nixpkgs=${toString ~/workspace/vcs/nixpkgs}"
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
          set --global pure_enable_git false
          printf "nix-shell "
        end

        # echo "❯"
        echo "λ"
      )

      set --global pure_symbol_prompt "$nix_shell_info"
    '';

    interactiveShellInit = ''

      # if terminal is TTY (TERM == linux), unset __HM_SESS_VARS_SOURCED,
      # because the graphical session will inherit this (which means child
      # applications will never re-source if necessary)
      if [ $TERM = "linux" ]
        set -e __HM_SESS_VARS_SOURCED
      end

      # GPG configuration
      set --global --export PINENTRY_USER_DATA gtk # nonstandard -- used by my pinentry script
      set --global --export SSH_AUTH_SOCK /run/user/(id -u)/gnupg/S.gpg-agent.ssh
      set --global --export GPG_TTY (tty)
      gpg-connect-agent updatestartuptty /bye >/dev/null &
      # ''${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye >/dev/null &

      # FIXME: "Fontconfig error: Cannot load config file from /etc/fonts/fonts.conf"
      # Probably related to not being NixOS
      set --global --export FONTCONFIG_FILE ${
        if config.fonts.fontconfig.enable then
          ''"${pkgs.fontconfig.out}/etc/fonts/fonts.conf"''
        else
          ''"/etc/fonts/fonts.conf"''
      }

      # Rust stuff
      if command -q rustc
        set --global --export --prepend LD_LIBRARY_PATH (rustc +nightly --print sysroot)"/lib"
        set --global --export RUST_SRC_PATH (rustc --print sysroot)"/lib/rustlib/src/rust/src"
      end

      eval (${pkgs.direnv}/bin/direnv hook fish) &

      emacs_start_daemon &
      t ls
      printf '\n'

      # Themed man output
      # from http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
      set --global --export LESS_TERMCAP_mb \e'[01;31m'                # begin blinking
      set --global --export LESS_TERMCAP_md \e'[01;38;5;74m'           # begin bold
      set --global --export LESS_TERMCAP_me \e'[0m'                    # end mode
      set --global --export LESS_TERMCAP_se \e'[0m'                    # end standout-mode
      set --global --export LESS_TERMCAP_so \e'[01;38;5;246;48;5;15m'  # begin standout-mode - info box and searches
      set --global --export LESS_TERMCAP_ue \e'[0m'                    # end underline
      set --global --export LESS_TERMCAP_us \e'[04;38;5;146m'          # begin underline
    '';
  };
}
