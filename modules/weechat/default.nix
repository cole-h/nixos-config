{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      weechat
      tmux
    ];

    activation = with lib; {
      weechatConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
        # WeeChat still does not support the XDG spec :'(
        $DRY_RUN_CMD ln -sfT $VERBOSE_ARG \
          ${toString ./config} \
          ${config.xdg.configHome}/weechat
      '';
    };
  };

  xdg.configFile = {
    "nixpkgs/modules/weechat/config/freenode.pem".source = config.lib.file.mkOutOfStoreSymlink ../../secrets/weechat/freenode.pem;
    "nixpkgs/modules/weechat/config/irc.conf".source = config.lib.file.mkOutOfStoreSymlink ../../secrets/weechat/irc.conf;
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
      Environment = [ "WEECHAT_HOME=${config.xdg.configHome}/weechat" ];
      ExecStart =
        "${pkgs.tmux}/bin/tmux -L weechat new -s weechat -d ${pkgs.weechat}/bin/weechat";
      ExecStartPost =
        "${pkgs.tmux}/bin/tmux -L weechat set status"; # turn off the status bar
      ExecStop = "${pkgs.tmux}/bin/tmux -L weechat set status kill-session -t weechat";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
