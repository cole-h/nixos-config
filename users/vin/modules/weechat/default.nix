{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    weechat
  ];

  xdg.configFile = {
    "weechat".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/flake/users/${config.home.username}/modules/weechat/config";
  };

  # NOTE: Only works well with lingering enabled -- otherwise systemd might kill
  # the service on logout (aka once there are no more user sessions)
  systemd.user.services."weechat" = {
    Unit = {
      Description = "A WeeChat client and relay service using Tmux";
      After = "network.target";
      Before = "shutdown.target";
      Conflicts = "shutdown.target";
    };

    Service = {
      Type = "forking";
      Environment = "WEECHAT_HOME=${config.xdg.configHome}/weechat";
      ExecStart = "${pkgs.tmux}/bin/tmux -L weechat new -s weechat -d ${pkgs.weechat}/bin/weechat";
      # turn off the status bar
      ExecStartPost = "${pkgs.tmux}/bin/tmux -L weechat set status";
      ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t weechat";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
