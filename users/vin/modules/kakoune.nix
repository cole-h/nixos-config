{ config, lib, pkgs, ... }:

{
  xdg.configFile = {
    "kak/colors/dracula.kak".source = pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "kakoune";
      rev = "6cca7256b02c9e7dad00ef3fea111eb0057c262b";
      sha256 = "177r62g7hyz9yxk58zi9yaw6qi69in9276phbx474g3r25iixhpl";
    } + "/colors/dracula.kak";
  };

  programs.kakoune = {
    enable = true;
    # config.colorScheme = "dracula";
    extraConfig = ''
      add-highlighter global/ number-lines -relative -hlcursor -separator " "

      hook global NormalKey y|d|c %{ nop %sh{
        printf %s "$kak_main_reg_dquote" | wl-copy >/dev/null 2>&1 &
      }}
    '';
  };
}
