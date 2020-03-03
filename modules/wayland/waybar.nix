{ pkgs, ... }:

{
  home.packages = with pkgs; [ waybar ];

  xdg.configFile = {
    "waybar/style.css".text = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "SF Display", Helvetica, Arial, sans-serif;
          font-size: 15px;
          min-height: 0;
      }

      window#waybar {
          background: #282a36;
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
          background: #282a36; /* dracula bg */
          border-bottom: 2px solid #BBBBBB;
      }

      #mode {
          background: #f8f8f2; /* dracula fg */
          color: #282a36; /* dracula bg */
      }

      #clock, #pulseaudio, #tray, #mode {
          padding: 0 7px;
      }

      #pulseaudio {
          padding: 0 7px;
      }

      #mpd {
          padding: 0 7px;
      }
    '';

    "waybar/config".text = ''
      {
          "position": "top", // Waybar position (top|bottom|left|right)
          "height": 30, // Waybar height
          "modules-left": [
              "sway/workspaces",
              "sway/mode"
          ],
          "modules-center": [
              "sway/window"
          ],
          "modules-right": [
              "mpd",
              "pulseaudio",
              "clock",
              "tray"
          ],
          // Modules configuration
          "sway/workspaces": {
              "disable-scroll": true,
              "all-outputs": false,
              "format": "{name} {icon}",
              "format-icons": {
                  "urgent": "",
                  "focused": "●",
                  "default": "○"
              }
          },
          "tray": {
              "spacing": 10
          },
          "clock": {
              "format": "{:%d %B %G %T}",
              "tooltip": false,
              "interval": 1
          },
          "pulseaudio": {
              "tooltip": false,
              "format": "{volume}%",
              "format-muted": "MUTED",
              "on-click": "pavucontrol"
          },
          "mpd": {
              "format": "{stateIcon} {artist} – {title} ♫",
              "format-disconnected": "Disconnected ♫",
              "format-stopped": "Stopped ♫",
              "interval": 1,
              "signal": 1,
              "max-length": 60,
              "unknown-tag": "N/A",
              "server": "localhost",
              "port": 6600,
              "on-click": "cantata",
              "state-icons": {
                  "paused": "||",
                  "playing": ">"
              },
              "tooltip": false
          }
      }
    '';
  };
}
