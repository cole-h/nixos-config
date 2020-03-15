{ config, pkgs, ... }:
let
  alacritty-sh = pkgs.writeShellScriptBin "alacritty.sh" ''
    focused=$(swaymsg -t get_tree | jq '.. | (.nodes? // empty)[] | select(.focused==true)')

    if [[ $(echo $focused | jq '.app_id') == '"Alacritty"' ]]; then
      # get child pid
      pid=$(pgrep -P $(echo $focused | jq '.pid'))

      # if child isn't our shell, climb parents until it is
      while [[ $pid -ne 1 && $(cat /proc/$pid/comm) != 'fish' ]]; do
        pid=$(ps -o ppid= -p $pid)
      done

      dir="$(readlink /proc/$pid/cwd)"

      exec env RUST_BACKTRACE=1 alacritty --working-directory "$dir" "$@" \
        ||   exec env RUST_BACKTRACE=1 alacritty "$@"
    else
      exec env RUST_BACKTRACE=1 alacritty "$@"
    fi
  '';
  drawterm-sh = pkgs.writeShellScriptBin "drawterm.sh" ''
    REC=$(slurp -w 2 -c a3a3a3 -b 00000000 -f "%w %h %x %y") || exit 1

    IFS=' ' read -r W H X Y <<< "$REC"

    if [[ "$W" -gt "1" && "$H" -gt "1" ]]; then
      (exec env RUST_BACKTRACE=1 alacritty --class "drawfloat" &)

      swaymsg -t subscribe -m '[ "window" ]' | while read -r event; do
        if [[ $(echo $event | jq '.container.app_id') == '"drawfloat"' ]]; then
          # set opacity to 1 to avoid flickering when changing side
          swaymsg [app_id="drawfloat"] floating enable, resize set $W $H, \
            move absolute position $X $Y, opacity 1
          break
        fi
      done
    fi
  '';
  # nixGLIntel = pkgs.writeExecutable {
  #   name = "nixGLIntel";
  #   text = ''
  #     #!/usr/bin/env sh
  #     export LIBGL_DRIVERS_PATH=${pkgs.mesa_drivers}/lib/dri
  #     export LD_LIBRARY_PATH=${pkgs.mesa_drivers}/lib:$LD_LIBRARY_PATH
  #     "$@"
  #   '';
  # };
in
{
  imports = [
    ./sway.nix # sway config
    ./waybar.nix # waybar config
  ];

  home.packages = with pkgs; [
    jq # json parsing
    grim # screenshot
    slurp # select region
    wl-clipboard # clipboard
    # alacritty
    # kitty
    mako # notifications
    libnotify # notifications part 2: electric boogaloo
    redshift-wlr # blue-light filter [overlays]
    bemenu # dmenu launcher [overlays]
    j4-dmenu-desktop # desktop files
    ly # TUI display manager
  ];

  systemd.user.services = {
    mako = {
      Unit = {
        Description = "mako";
        Documentation = [ "man:mako(1)" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.mako}/bin/mako --default-timeout 5000";
        RestartSec = 3;
        Restart = "always";
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };

    polkit = {
      Unit = {
        Description = "polkit-gnome";
        Documentation = [ "man:polkit(8)" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        RestartSec = 3;
        Restart = "always";
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };

    redshift = {
      Unit = {
        Description = "redshift";
        Documentation = [ "man:redshift(1)" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.redshift-wlr}/bin/redshift -t 6500:3000 -l 38.6768616:-121.138903";
        RestartSec = 3;
        Restart = "always";
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };

    sway = {
      Unit = {
        Description = "sway";
        Documentation = [ "man:sway(5)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };

      Service = {
        Type = "simple";
        Environment = [
          "LD_LIBRARY_PATH=${pkgs.mesa_drivers}/lib"
          "LIBGL_DRIVERS_PATH=${pkgs.mesa_drivers}/lib/dri"
        ];
        ExecStart = "${config.wayland.windowManager.sway.package}/bin/sway --debug";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    swayidle = {
      Unit = {
        Description = "swayidle";
        Documentation = [ "man:swayidle(1)" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.swayidle}/bin/swayidle -w \
            timeout 1200 '${pkgs.swaylock}/bin/swaylock -f -i ${config.my.wallpaper} --scaling fill' \
            timeout 1500 'swaymsg "output * dpms off"' \
              resume 'swaymsg "output * dpms on"' \
            before-sleep '${pkgs.swaylock}/bin/swaylock -f -i ${config.my.wallpaper} --scaling fill'
        '';
        RestartSec = 3;
        Restart = "always";
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };

    waybar = {
      Unit = {
        Description = "waybar";
        Documentation = [ "https://github.com/Alexays/Waybar/wiki" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.waybar}/bin/waybar";
        RestartSec = 3;
        Restart = "always";
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };
  };
}
