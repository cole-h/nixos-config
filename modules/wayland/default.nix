{ config, lib, pkgs, ... }:

let
  # swayrun = with pkgs;
  #   writeShellScriptBin "swayrun" ''
  #     export __HM_SESS_VARS_SOURCED=
  #     export NIX_PATH=
  #     export FONTCONFIG_FILE=/etc/fonts/fonts.conf

  #     # export SSH_AUTH_SOCK="/run/user/$(id -u)/gnupg/S.gpg-agent.ssh"

  #     export GDK_BACKEND=wayland
  #     # export QT_QPA_PLATFORM=wayland
  #     # export SDL_VIDEODRIVER=wayland
  #     export _JAVA_AWT_WM_NONREPARENTING=1

  #     # TODO: Japanese input stuff
  #     # export GTK_IM_MOUDLE=xim
  #     # export XMODIFIERS=@im=ibus
  #     # export QT_IM_MODULE=ibus

  #     sway $@ > /tmp/sway.log 2>&1 && systemctl stop --user sway-session.target
  #   '';
  alacritty-sh = with pkgs;
    writeShellScriptBin "alacritty.sh" ''
      focused=$(swaymsg -t get_tree | jq '.. | (.nodes? // empty)[] | select(.focused==true)')

      if [[ $(echo $focused | jq '.app_id') == '"Alacritty"' ]]; then
          # get child pid
          pid=$(pgrep -P $(echo $focused | jq '.pid'))

          # if child isn't our shell, climb parents until it is
          while [[ $pid -ne 1 && $(cat /proc/$pid/comm) != 'fish' ]]; do
              pid=$(ps -o ppid= -p $pid)
          done

          dir="$(readlink /proc/$pid/cwd)"
          exec env RUST_BACKTRACE=1 alacritty --working-directory "$dir" "$@"
      else
          exec env RUST_BACKTRACE=1 alacritty "$@"
      fi
    '';
  drawterm-sh = with pkgs;
    writeShellScriptBin "drawterm.sh" ''
      REC=$(slurp -w 2 -c a3a3a3 -b 00000000 -f "%w %h %x %y") || exit 1

      IFS=' ' read -r W H X Y <<< "$REC"

      if [[ "$W" -gt "1" && "$H" -gt "1" ]]; then
          (exec env RUST_BACKTRACE=1 alacritty --class "drawfloat" &)

          swaymsg -t subscribe -m '[ "window" ]' | while read -r event; do
              if [[ $(echo $event | jq '.container.app_id') == '"drawfloat"' ]]; then
                  # set opacity to 1 to avoid flickering when changing size
                  swaymsg [app_id="drawfloat"] floating enable, resize set $W $H, \
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

  home.packages = with pkgs; [
    jq
    grim
    slurp
    wl-clipboard
    # alacritty
    # kitty
  ];

  # home.file."swayrun" = {
  #   source = swayrun;
  #   executable = true;
  # };

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
          Restart = "on-failure";
        };

        Install.WantedBy = [ "sway-session.target" ];
      };
    };
  };
}
