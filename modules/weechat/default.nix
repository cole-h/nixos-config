{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [ weechat tmux ];

    activation = with lib; {
      weechatSecrets = hm.dag.entryBefore [ "weechatConfig" ] ''
        $DRY_RUN_CMD unlink ${toString ./weechat-conf/sec.conf} || true
        $DRY_RUN_CMD ln -s $VERBOSE_ARG \
          ${toString <vin/secrets/weechat/sec.conf>} \
          ${toString ./weechat-conf/sec.conf}

        $DRY_RUN_CMD unlink ${toString ./weechat-conf/irc.conf} || true
        $DRY_RUN_CMD ln -s $VERBOSE_ARG \
          ${toString <vin/secrets/weechat/irc.conf>} \
          ${toString ./weechat-conf/irc.conf}
      '';

      weechatConfig = hm.dag.entryAfter [ "linkGeneration" ] ''
        $DRY_RUN_CMD unlink ${config.xdg.configHome}/weechat || true
        # $DRY_RUN_CMD unlink ${config.home.homeDirectory}/.weechat || true
        $DRY_RUN_CMD ln -s $VERBOSE_ARG \
          ${toString ./weechat-conf} ${config.xdg.configHome}/weechat
        # $DRY_RUN_CMD ln -s $VERBOSE_ARG \
        #   ${toString ./weechat-conf} ${config.home.homeDirectory}/.weechat
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
        "${pkgs.tmux}/bin/tmux -L weechat new -d -s weechat ${pkgs.weechat}/bin/weechat";
      EexecStartPost =
        "${pkgs.tmux}/bin/tmux -L weechat set status"; # turn off the status bar
      ExecStop = "${pkgs.tmux}/bin/tmux -L weechat kill-session -t weechat";
    };

    Install.WantedBy = [ "multi-user.target" ];
  };
}
