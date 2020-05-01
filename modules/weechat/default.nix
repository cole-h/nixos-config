{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      weechat
      tmux
    ];

    activation = with lib; {
      weechatSecrets = hm.dag.entryBefore [ "weechatConfig" ] ''
        $DRY_RUN_CMD unlink \
          ${toString ./weechat-conf/freenode.pem} 2>/dev/null || true
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
          ${toString ../../secrets/weechat/freenode.pem} \
          ${toString ./weechat-conf/freenode.pem}

        $DRY_RUN_CMD unlink \
          ${toString ./weechat-conf/sec.conf} 2>/dev/null || true
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
          ${toString ../../secrets/weechat/sec.conf} \
          ${toString ./weechat-conf/sec.conf}

        $DRY_RUN_CMD unlink \
          ${toString ./weechat-conf/irc.conf} 2>/dev/null || true
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
          ${toString ../../secrets/weechat/irc.conf} \
          ${toString ./weechat-conf/irc.conf}
      '';

      weechatConfig = hm.dag.entryAfter [ "linkGeneration" ] ''
        # WeeChat still does not support the XDG spec :'(
        $DRY_RUN_CMD unlink \
          ${config.xdg.configHome}/weechat 2>/dev/null || true
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
          ${toString ./weechat-conf} ${config.xdg.configHome}/weechat
      '';
    };
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
      ExecStop = "${pkgs.tmux}/bin/tmux -L weechat kill-session -t weechat";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
