{ pkgs, lib, ... }:
let
  waybar-config = {
    layer = "top";
    position = "top"; # Waybar position (top|bottom|left|right);
    height = 25; # Waybar height;

    modules-left = [
      "sway/workspaces"
      "sway/mode"
    ];

    modules-center = [
      "sway/window"
    ];

    modules-right = [
      # "mpd"
      # "custom/mpd"
      "pulseaudio"
      "clock"
      "tray"
    ];

    # "custom/mpd" = {
    #   exec = toString ~/workspace/langs/c/mpd/mpdinfo;
    #   on-click = "${pkgs.cantata}/bin/cantata";
    #   format = "{} ";
    #   interval = "0";
    #   tooltip = false;
    # };

    # Modules configuration
    "sway/workspaces" = {
      disable-scroll = true;
      all-outputs = false;
      format = "{name} {icon}";

      format-icons = {
        urgent = "";
        focused = "●";
        default = "○";
      };
    };

    tray = {
      spacing = 10;
    };

    clock = {
      tooltip-format = "{calendar}";
      format = "{:%d %B %G %T}";
      tooltip = true;
      interval = 1;
    };

    pulseaudio = {
      tooltip = false;
      format = "{volume}%";
      format-muted = "MUTED";
      on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
    };

    mpd = {
      format = "{stateIcon} {artist} – {title} ♫";
      format-disconnected = "Disconnected ♫";
      format-stopped = "Stopped ♫";
      interval = 1;
      signal = 1;
      max-length = 60;
      unknown-tag = "N/A";
      server = "localhost";
      port = 6600;
      on-click = "${pkgs.cantata}/bin/cantata";
      tooltip = false;

      state-icons = {
        paused = "||";
        playing = ">";
      };
    };
  };
in
{
  # TODO: just use default swaybar, but need to get mpd and volume widgets
  home.packages = with pkgs; [
    waybar # [overlays]
  ];

  xdg.configFile = {
    "waybar/style.css".text = ''
      * {
          border: none;
          border-radius: 0;
          font-family: Iosevka Custom Book Extended, Roboto, Helvetica, Arial, sans-serif;
          font-size: 14px;
          min-height: 0;
      }

      window#waybar {
          background: #282A36;
          color: #CCC;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #CCC;
          border-bottom: 2px solid transparent;
      }

      #workspaces button.focused {
          background: #282A36; /* dracula bg */
          border-bottom: 2px solid #BBBBBB;
      }

      #mode {
          background: #F8F8F2; /* dracula fg */
          color: #282A36; /* dracula bg */
      }

      #clock, #pulseaudio, #tray, #mode, #mpd {
          padding: 0 7px;
      }
    '';

    "waybar/config".text = builtins.toJSON waybar-config;
  };
}
