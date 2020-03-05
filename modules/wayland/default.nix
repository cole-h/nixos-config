{ config, lib, pkgs, ... }:

let
  swayrun = with pkgs;
    writeShellScriptBin "swayrun" ''
      # export __HM_SESS_VARS_SOURCED=
      # export SSH_AUTH_SOCK="/run/user/$(${coreutils}/bin/id -u)/gnupg/S.gpg-agent.ssh"

      export GDK_BACKEND=wayland
      # export QT_QPA_PLATFORM=wayland
      # export SDL_VIDEODRIVER=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
      # export XDG_CURRENT_DESKTOP=Unity # required for tray icons in Waybar
      export FONTCONFIG_FILE=/etc/fonts/fonts.conf # probably unnecessary for NixOS

      # TODO: Japanese input stuff
      # export GTK_IM_MOUDLE=xim
      # export XMODIFIERS=@im=ibus
      # export QT_IM_MODULE=ibus

      # dbus-launch --sh-syntax --exit-with-session sway &>/tmp/sway.log $@ \
      ${sway}/bin/sway \
        &>/tmp/sway.log $@ \
        && ${systemd}/bin/systemctl stop --user sway-session.target \
        && ${jack2}/bin/jack_control exit && ${pulseaudioFull}/bin/pulseaudio -k
    '';
  alacritty-sh = with pkgs;
    writeShellScriptBin "alacritty.sh" ''
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
          exec env RUST_BACKTRACE=1 ${alacritty}/bin/alacritty "$@"
      fi
    '';
  drawterm-sh = with pkgs;
    writeShellScriptBin "drawterm.sh" ''
      REC=$(${slurp}/bin/slurp -w 2 -c a3a3a3 -b 00000000 -f "%w %h %x %y") || exit 1

      IFS=' ' read -r W H X Y <<< "$REC"

      if [[ "$W" -gt "1" && "$H" -gt "1" ]]; then
          (exec env RUST_BACKTRACE=1 ${alacritty}/bin/alacritty --class "drawfloat" &)

          ${sway}/bin/swaymsg -t subscribe -m '[ "window" ]' | while read -r event; do
              if [[ $(echo $event | jq '.container.app_id') == '"drawfloat"' ]]; then
                  # set opacity to 1 to avoid flickering when changing side
                  ${sway}/bin/swaymsg [app_id="drawfloat"] floating enable, resize set $W $H, \
                      move absolute position $X $Y, opacity 1
                  break
              fi
          done
      fi
    '';
in {
  imports = [
    ./sway.nix # sway config
    ./waybar.nix # waybar config
  ];

  # TODO: sway config, etc
  home.packages = with pkgs;
    [
      # sway
      # alacritty
      # cadence
    ];

  home.file."swayrun" = {
    source = swayrun;
    executable = true;
  };

  systemd.user = {
    # targets = {
    #   sway-session = {
    #     Unit = {
    #       Description = "sway compositor session";
    #       Documentation = "man:systemd.special(7)";
    #       BindsTo = [ "graphical-session.target" ];
    #       Wants = [ "graphical-session-pre.target" ];
    #       After = [ "graphical-session-pre.target" ];
    #     };
    #   };
    # };

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
    };
  };
}
