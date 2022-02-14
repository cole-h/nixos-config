{ config, pkgs, lib, my, ... }:
{
  home.packages = [ pkgs.sqlite ]; # zsh-histdb

  programs.zsh = {
    enable = true;
    shellAliases = {
      t = "todo.sh";
      nix-locate = "command nix-locate --top-level";
      ssh = "env TERM=xterm-256color ssh";
    };

    initExtraFirst = ''
      zmodload zsh/zprof
    '';

    initExtra = ''
      source ~/.z4h.zsh
    '';
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
