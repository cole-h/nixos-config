{ config, pkgs, lib, ... }:
{
  home.packages = [ pkgs.sqlite ]; # zsh-histdb
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma";
          repo = "fast-syntax-highlighting";
          rev = "a62d721affc771de2c78201d868d80668a84c1e1";
          sha256 = "4xJXH9Wn18/+Vfib/ZrhCRp/yB1PppsbZCx1/WafmU8=";
        };
      }
      {
        name = "powerlevel10k";
        file = "powerlevel10k.zsh-theme";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "3920940ea84f6fba767cbed3fe6ba0653411c706";
          sha256 = "07+IH9c/QfLtpq5KFUKQnf8Ug1jQwjb50UHy/OEfUcM=";
        };
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "ae315ded4dba10685dbbafbfa2ff3c1aefeb490d";
          sha256 = "xv4eleksJzomCtLsRUj71RngIJFw8+A31O6/p7i4okA=";
        };
      }
      {
        name = "zsh-histdb";
        src = pkgs.fetchFromGitHub {
          owner = "larkery";
          repo = "zsh-histdb";
          rev = "5d492b4d0e2638588b1520f0ff0d768c729f6565";
          sha256 = "azGuVr9NRTNexJ1FH/AVeo9VdgK+S4NTI59q0HB1S0c=";
        };
      }
    ];

    initExtra = ''
      autoload -Uz add-zsh-hook

      setopt autocd
      setopt autopushd

      ## based off of https://github.com/zigius/expand-ealias.plugin.zsh and https://github.com/olets/zsh-abbr/
      typeset -g -A abbrs
      abbrs=()

      abbr()
      {
        emulate -LR zsh

        abbrs[$1]=$2
      }

      _abbr_expand()
      {
        emulate -LR zsh

        local expansion
        local word
        local words
        local -i word_count

        words=(''${(z)LBUFFER})
        word=$words[-1]
        word_count=''${#words}

        if [[ $word_count == 1 ]]; then
          expansion=''${abbrs[$word]}
        fi

        if [[ -n $expansion ]]; then
          local preceding_lbuffer
          preceding_lbuffer=''${LBUFFER%%$word}
          LBUFFER=$preceding_lbuffer''${(Q)expansion}
        fi
      }

      _abbr_expand_and_accept()
      {
        emulate -LR zsh

        local trailing_space
        trailing_space=''${LBUFFER##*[^[:IFSSPACE:]]}

        if [[ -z $trailing_space ]]; then
          zle _abbr_expand
        fi

        zle accept-line
      }

      _abbr_expand_and_space()
      {
        emulate -LR zsh

        _abbr_expand
        zle self-insert
      }

      zle -N _abbr_expand
      zle -N _abbr_expand_and_accept
      zle -N _abbr_expand_and_space

      bindkey " " _abbr_expand_and_space
      bindkey "^ " magic-space
      bindkey -M isearch "^ " _abbr_expand_and_space
      bindkey -M isearch " " magic-space
      bindkey "^M" _abbr_expand_and_accept

      ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(_abbr_expand_and_accept)

      ${builtins.concatStringsSep "\n"
        (lib.mapAttrsToList
          (k: v: ''abbr ${k} ${lib.escapeShellArg v}'')
          config.programs.fish.shellAbbrs)}

      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      _zsh_autosuggest_strategy_histdb_top() {
          local query="select commands.argv from
      history left join commands on history.command_id = commands.rowid
      left join places on history.place_id = places.rowid
      where commands.argv LIKE '$(sql_escape $1)%'
      group by commands.argv
      order by places.dir != '$(sql_escape $PWD)', count(*) desc limit 1"
          suggestion=$(_histdb_query "$query")
      }

      ZSH_AUTOSUGGEST_STRATEGY=histdb_top

      # make completion allow an all-undercase string to be completed
      # to something with uppercase e.g. `asdf` -> `Asdf`
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

      # make ^W behave better
      autoload -U select-word-style
      select-word-style bash
    '';

    initExtraFirst = ''
      zmodload zsh/zprof

      ## https://wiki.archlinux.org/index.php/zsh#Key_bindings
      # create a zkbd compatible hash;
      # to add other keys to this hash, see: man 5 terminfo
      typeset -g -A key

      key[Home]="''${terminfo[khome]}"
      key[End]="''${terminfo[kend]}"
      key[Insert]="''${terminfo[kich1]}"
      key[Backspace]="''${terminfo[kbs]}"
      key[Delete]="''${terminfo[kdch1]}"
      key[Up]="''${terminfo[kcuu1]}"
      key[Down]="''${terminfo[kcud1]}"
      key[Left]="''${terminfo[kcub1]}"
      key[Right]="''${terminfo[kcuf1]}"
      key[PageUp]="''${terminfo[kpp]}"
      key[PageDown]="''${terminfo[knp]}"
      key[Shift-Tab]="''${terminfo[kcbt]}"
      key[Ctrl-Left]="''${terminfo[kLFT5]}"
      key[Ctrl-Right]="''${terminfo[kRIT5]}"

      # setup key accordingly
      [[ -n "''${key[Home]}"       ]] && bindkey -- "''${key[Home]}"       beginning-of-line
      [[ -n "''${key[End]}"        ]] && bindkey -- "''${key[End]}"        end-of-line
      [[ -n "''${key[Insert]}"     ]] && bindkey -- "''${key[Insert]}"     overwrite-mode
      [[ -n "''${key[Backspace]}"  ]] && bindkey -- "''${key[Backspace]}"  backward-delete-char
      [[ -n "''${key[Delete]}"     ]] && bindkey -- "''${key[Delete]}"     delete-char
      [[ -n "''${key[Up]}"         ]] && bindkey -- "''${key[Up]}"         up-line-or-history
      [[ -n "''${key[Down]}"       ]] && bindkey -- "''${key[Down]}"       down-line-or-history
      [[ -n "''${key[Left]}"       ]] && bindkey -- "''${key[Left]}"       backward-char
      [[ -n "''${key[Right]}"      ]] && bindkey -- "''${key[Right]}"      forward-char
      [[ -n "''${key[PageUp]}"     ]] && bindkey -- "''${key[PageUp]}"     beginning-of-buffer-or-history
      [[ -n "''${key[PageDown]}"   ]] && bindkey -- "''${key[PageDown]}"   end-of-buffer-or-history
      [[ -n "''${key[Shift-Tab]}"  ]] && bindkey -- "''${key[Shift-Tab]}"  reverse-menu-complete
      [[ -n "''${key[Ctrl-Left]}"  ]] && bindkey -- "''${key[Ctrl-Left]}"  backward-word
      [[ -n "''${key[Ctrl-Right]}" ]] && bindkey -- "''${key[Ctrl-Right]}" forward-word

      # Finally, make sure the terminal is in application mode, when zle is
      # active. Only then are the values from $terminfo valid.
      if (( ''${+terminfo[smkx]} && ''${+terminfo[rmkx]} )); then
        autoload -Uz add-zle-hook-widget
        function zle_application_mode_start { echoti smkx }
        function zle_application_mode_stop { echoti rmkx }
        add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
        add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
      fi

      # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n]
      # confirmations, etc.) must go above this block; everything else may go below.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';

    defaultKeymap = "emacs";
  };

}
