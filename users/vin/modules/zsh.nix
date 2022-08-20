{ config, pkgs, lib, my, ... }:
{
  # TODO: yoink the keybinding stuff from z4h
  # I don't like that ^W deletes "~/.config|" if my cursor is at | -- it should only delete `.config` and leave me with `~/`
  # TODO: yoink the cwd stuff from z4h -- so Ctrl-Shift-N works
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableVteIntegration = true;

    autocd = true;

    history = {
      extended = true;
      save = 1000000;
      size = 1000000;
    };

    shellAliases = {
      t = "todo.sh";
      nix-locate = "command nix-locate --top-level";
      ssh = "env TERM=xterm-256color ssh";
    };

    initExtraFirst = ''
      zmodload zsh/zprof
      export ATUIN_NOBIND=true

      path+=(
        $HOME/.cargo/bin
      )
    '';

    initExtra = ''
      zle -N _atuinr_widget _atuinr
      _atuinr() {
          LBUFFER="$(atuin history list --cmd-only | uniq -u | fzf --tac)"
          zle redisplay
      }
      bindkey '^r' _atuinr_widget

      source $HOME/.keys.zsh
      source $HOME/.abbrs.zsh

      unsetopt extendedglob
      setopt inc_append_history

      typeset -ga ZSH_HIGHLIGHT_DIRS_BLACKLIST
      export ZSH_HIGHLIGHT_DIRS_BLACKLIST=(/nix/store)
      export WORDCHARS=''${WORDCHARS//[\/~]}
    '';

    plugins = [
      {
        name = "zsh-history-substring-search";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-history-substring-search";
          rev = "4abed97b6e67eb5590b39bcd59080aa23192f25d";
          sha256 = "sha256-8kiPBtgsjRDqLWt0xGJ6vBBLqCWEIyFpYfd+s1prHWk=";
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "13dd94ba828328c18de3f216ec4a746a9ad0ef55";
          sha256 = "sha256-Vc/i0W+beKphNisGFS435r+9IL6BhQsYeGAFRlP8+tA=";
        };
      }
    ];
  };
  
  home.file.".abbrs.zsh".text = ''
    ## based off of https://github.com/zigius/expand-ealias.plugin.zsh and https://github.com/olets/zsh-abbr/
    typeset -g -A abbrs
    abbrs=()

    abbr() {
      emulate -LR zsh

      abbrs[$1]=$2
    }

    _abbr_expand() {
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

    _abbr_expand_and_accept() {
      emulate -LR zsh

      local trailing_space
      trailing_space=''${LBUFFER##*[^[:IFSSPACE:]]}

      if [[ -z $trailing_space ]]; then
        zle _abbr_expand
      fi

      zle accept-line
    }

    _abbr_expand_and_space() {
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
  '' +
  (
    let
      abbrs = {
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
      } // (pkgs.callPackage my.drvs.cgitc { }).abbrs;
    in
    builtins.concatStringsSep "\n"
      (lib.mapAttrsToList
        (k: v: ''
          abbr ${k} ${lib.escapeShellArg v}
          alias ${k}=${lib.escapeShellArg v}
        '')
        abbrs)
  );
}
