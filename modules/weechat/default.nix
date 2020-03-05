{ config, lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [ weechat tmux ];

    activation = with lib; {
      weechatConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD unlink ${config.xdg.configHome}/weechat || true
        # $DRY_RUN_CMD unlink ${config.home.homeDirectory}/.weechat || true
        $DRY_RUN_CMD ln -s $VERBOSE_ARG \
          ${toString ./weechat-conf} ${config.xdg.configHome}/weechat
        # $DRY_RUN_CMD ln -s $VERBOSE_ARG \
        #   ${toString ./weechat-conf} ${config.home.homeDirectory}/.weechat
      '';
    };
  };
  # TODO: see if there's a way to link directly to .source without adding it to store
  # xdg.configFile."weechat".source = "${toString ./weechat-conf}";
  # home.file.".weechat".source = "${toString ./weechat}";

  # NOTE: Only works well with lingering enabled -- otherwise systemd might kill
  # the service on logout (aka once there are no more user sessions).
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
      ExecStop = "${pkgs.tmux}/bin/tmux -L weechat kill-session -t weechat";
    };

    Install.WantedBy = [ "multi-user.target" ];
  };
}
