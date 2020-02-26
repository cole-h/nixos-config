# general configuration
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ mako redshift-wlr ];

  systemd.user = {
    targets = {
      sway-session = {
        Unit = {
          Description = "sway compositor session";
          Documentation = "man:systemd.special(7)";
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };
    };

    services = {
      # redshift
      redshift = {
        Unit = {
          Description = "Redshift display colour temperature adjustment";
          Documentation = "http://jonls.dk/redshift/";
        };

        Service = {
          ExecStart = "${pkgs.redshift-wlr}/bin/redshift";
          Restart = "always";
        };

        Install.WantedBy = [ "sway-session.target" ];
      };

      # mako
      mako = {
        Unit = {
          Description = "A lightweight Wayland notification daemon";
          Documentation = "man:mako(1)";
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.mako}/bin/mako --default-timeout 3000";
        };

        Install.WantedBy = [ "sway-session.target" ];
      };
    };
  };
}
