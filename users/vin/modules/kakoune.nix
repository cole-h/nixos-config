{ config, lib, pkgs, ... }:

{
  programs.kakoune = {
    enable = true;
    extraConfig = ''
      add-highlighter global/ number-lines -relative -hlcursor -separator " "

      hook global NormalKey y|d|c %{ nop %sh{
        printf %s "$kak_main_reg_dquote" | wl-copy >/dev/null 2>&1 &
      }}
    '';
  };
}
