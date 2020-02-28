# general configuration
{ config, lib, pkgs, ... }:

let
  alacritty-sh = with pkgs;
    writeShellScriptBin "alacritty.sh" ''
      # TODO: set floating && resize set <width> <height> && move absolute position <pos-x> <pos-y>
      focused=$(${sway}/bin/swaymsg -t get_tree | ${jq}/bin/jq '.. | (.nodes? // empty)[] | select(.focused==true)')

      if [[ $(echo $focused | ${jq}/bin/jq '.app_id') == '"Alacritty"' ]]; then
          # get child pid
          pid=$(${procps-ng}/bin/pgrep -P $(echo $focused | ${jq}/bin/jq '.pid'))

          # if child isn't our shell, climb parents until it is
          while [[ $pid -ne 1 && $(${coreutils}/bin/cat /proc/$pid/comm) != 'fish' ]]; do
              pid=$(${procps-ng}/bin/ps -o ppid= -p $pid)
          done

          dir="$(${coreutils}/bin/readlink /proc/$pid/cwd)"
          exec ${coreutils}/bin/env RUST_BACKTRACE=1 ${alacritty}/bin/alacritty --working-directory "$dir" "$@"
      else
          exec env RUST_BACKTRACE ${alacritty}/bin/alacritty "$@"
      fi
    '';
in {
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
