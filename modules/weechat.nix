{ config, lib, pkgs, ... }:

{
  # TODO: actual config part
  xdg.configFile."weechat".source = ./weechat;

  systemd.user.services."weechat" = {
    Unit = {
      Description = "A WeeChat client and relay service using GNU screen";
      After = "network.target";
    };

    Service = {
      Type = "simple";
      User = "${config.home.username}";
      Environment = [ "WEECHAT_HOME=${config.xdg.configHome}/weechat" ];
      ExecStart = "/usr/bin/screen -D -m -fa -S weechat /usr/bin/weechat";
      ExecStop = "/usr/bin/screen -S weechat -X quit";
    };

    Install.WantedBy = [ "multi-user.target" ];
  };
}
