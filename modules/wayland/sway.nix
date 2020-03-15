{ config, ... }:
let
  ## Variables for bindings
  # Logo key
  modifier = "Mod4";
  # Alt key
  meta = "Mod1";
  # Home row direction keys, like vim
  up = "k";
  down = "j";
  left = "h";
  right = "l";

  ## Modes
  system = "System: (l) lock, (e) logout, (s) suspend";
  screenie = "(a) area, (m) monitor, (w) window, (A) to clipboard, (M) to clipboard, (W) to clipboard";

  ## Executables
  term = toString ~/scripts/alacritty.sh;
  alacritty = "env RUST_BACKTRACE=1 alacritty";
  kitty = "kitty";
  menu = ''
    j4-dmenu-desktop --dmenu="bemenu --grab --ignorecase" \
        --usage-log=$HOME/.cache/.j4_history
  '';
  # menu = "rofi -show drun -show-icons -normal-window";

  ## Workspaces
  # output DP-2 (left)
  ws1 = "1";
  ws2 = "2";
  ws3 = "3";
  ws4 = "4";
  ws5 = "5";
  ws6 = "6";
  ws7 = "7";
  ws8 = "8";
  ws9 = "9";
  ws10 = "10";
  # output HDMI-A-1 (right)
  wsF1 = "11";
  wsF2 = "12";
  wsF3 = "13";
  wsF4 = "14";
  wsF5 = "15";
  wsF6 = "16";
  wsF7 = "17";
  wsF8 = "18";
  wsF9 = "19";
  wsF10 = "20";
in
{
  wayland.windowManager.sway = {
    enable = true;

    systemdIntegration = true;
    xwayland = true;
    wrapperFeatures = { gtk = true; };

    extraSessionCommands = ''
      export __HM_SESS_VARS_SOURCED= # in order to allow further sessionVariables modifications to take effect

      export SSH_AUTH_SOCK="/run/user/$(id -u)/gnupg/S.gpg-agent.ssh"

      export MOZ_ENABLE_WAYLAND=1
      # export QT_QPA_PLATFORM=wayland
      # export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      # export QT_WAYLAND_FORCE_DPI=physical
      # export SDL_VIDEODRIVER=wayland
      export GDK_BACKEND=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
      export XDG_CURRENT_DESKTOP=Unity
    '';

    config = rec {
      output = {
        "*".bg = "${config.my.wallpaper} fit";
        "DP-2" = {
          resolution = "1920x1080";
          position = "0,0";
          scale = "1";
        };
        "HDMI-A-1" = {
          resolution = "1920x1080";
          position = "1920,0";
          scale = "1";
        };
      };

      gaps = {
        inner = 5;
        outer = 5;
        smartGaps = true;
      };

      fonts = [ "IPAexGothic 11" "DejaVu Sans Mono 10" ];

      input = {
        "6940:6931:Corsair_Corsair_K70_RGB_Gaming_Keyboard__Keyboard" = {
          xkb_numlock = "enabled";
          xkb_capslock = "disabled";
        };

        "1133:16487:Logitech_G903" = {
          accel_profile = "flat";
          pointer_accel = "0";
        };
      };

      inherit modifier;

      # Drag floating windows by holding down $mod and left mouse button.
      # Resize them with right mouse button + $mod.
      # Despite the name, also works for non-floating windows.
      # Change normal to inverse to use left mouse button for resizing and right
      # mouse button for dragging.
      floating.modifier = "${modifier}";

      keybindings = {
        "Ctrl+Alt+l" = "exec swaylock -f -i ${config.my.wallpaper} --scaling fill";

        ## Basics
        # start a terminal
        "${modifier}+Return" = "exec ${term}";
        "${modifier}+Shift+Return" = "exec ${alacritty}";
        "${modifier}+${meta}+Shift+Return" = "exec ${kitty}";
        # kill focused window
        "${modifier}+Shift+q" = "kill";
        # start your launcher
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+m" = "exec rofi -show emoji -normal-window";
        # reload the configuration file
        "${modifier}+Shift+c" = "reload";
        # open file browser
        # TODO: add nautilus, also check gsettings I have set
        "${modifier}+e" = "exec nautilus";
        # open password menu
        "${modifier}+p" = "exec ~/scripts/passmenu";
        "${modifier}+Shift+p" = "exec ~/scripts/otpmenu";
        # paste to paste.sr.ht
        "${modifier}+c" = "exec ~/scripts/paste";

        ## Moving around
        # Move your focus around
        "${modifier}+${up}" = "focus up";
        "${modifier}+${down}" = "focus down";
        "${modifier}+${left}" = "focus left";
        "${modifier}+${right}" = "focus right";
        # or use $mod+[up|down|left|right]
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";
        # _move_ the focused window with the same, but add Shift
        "${modifier}+Shift+${up}" = "move up";
        "${modifier}+Shift+${down}" = "move down";
        "${modifier}+Shift+${left}" = "move left";
        "${modifier}+Shift+${right}" = "move right";
        # ditto, with arrow keys
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

        ## Workspaces
        # switch to workspace
        "${modifier}+1" = "workspace ${ws1}";
        "${modifier}+2" = "workspace ${ws2}";
        "${modifier}+3" = "workspace ${ws3}";
        "${modifier}+4" = "workspace ${ws4}";
        "${modifier}+5" = "workspace ${ws5}";
        "${modifier}+6" = "workspace ${ws6}";
        "${modifier}+7" = "workspace ${ws7}";
        "${modifier}+8" = "workspace ${ws8}";
        "${modifier}+9" = "workspace ${ws9}";
        "${modifier}+0" = "workspace ${ws10}";
        "${modifier}+F1" = "workspace ${wsF1}";
        "${modifier}+F2" = "workspace ${wsF2}";
        "${modifier}+F3" = "workspace ${wsF3}";
        "${modifier}+F4" = "workspace ${wsF4}";
        "${modifier}+F5" = "workspace ${wsF5}";
        "${modifier}+F6" = "workspace ${wsF6}";
        "${modifier}+F7" = "workspace ${wsF7}";
        "${modifier}+F8" = "workspace ${wsF8}";
        "${modifier}+F9" = "workspace ${wsF9}";
        "${modifier}+F10" = "workspace ${wsF10}";
        "${modifier}+KP_1" = "workspace ${wsF1}";
        "${modifier}+KP_2" = "workspace ${wsF2}";
        "${modifier}+KP_3" = "workspace ${wsF3}";
        "${modifier}+KP_4" = "workspace ${wsF4}";
        "${modifier}+KP_5" = "workspace ${wsF5}";
        "${modifier}+KP_6" = "workspace ${wsF6}";
        "${modifier}+KP_7" = "workspace ${wsF7}";
        "${modifier}+KP_8" = "workspace ${wsF8}";
        "${modifier}+KP_9" = "workspace ${wsF9}";
        "${modifier}+KP_0" = "workspace ${wsF10}";
        # move focused container to workspace
        "${modifier}+Shift+1" = "move container to workspace ${ws1}";
        "${modifier}+Shift+2" = "move container to workspace ${ws2}";
        "${modifier}+Shift+3" = "move container to workspace ${ws3}";
        "${modifier}+Shift+4" = "move container to workspace ${ws4}";
        "${modifier}+Shift+5" = "move container to workspace ${ws5}";
        "${modifier}+Shift+6" = "move container to workspace ${ws6}";
        "${modifier}+Shift+7" = "move container to workspace ${ws7}";
        "${modifier}+Shift+8" = "move container to workspace ${ws8}";
        "${modifier}+Shift+9" = "move container to workspace ${ws9}";
        "${modifier}+Shift+0" = "move container to workspace ${ws10}";
        "${modifier}+Shift+F1" = "move container to workspace ${wsF1}";
        "${modifier}+Shift+F2" = "move container to workspace ${wsF2}";
        "${modifier}+Shift+F3" = "move container to workspace ${wsF3}";
        "${modifier}+Shift+F4" = "move container to workspace ${wsF4}";
        "${modifier}+Shift+F5" = "move container to workspace ${wsF5}";
        "${modifier}+Shift+F6" = "move container to workspace ${wsF6}";
        "${modifier}+Shift+F7" = "move container to workspace ${wsF7}";
        "${modifier}+Shift+F8" = "move container to workspace ${wsF8}";
        "${modifier}+Shift+F9" = "move container to workspace ${wsF9}";
        "${modifier}+Shift+F10" = "move container to workspace ${wsF10}";
        "${modifier}+Shift+KP_End" = "move container to workspace ${wsF1}";
        "${modifier}+Shift+KP_Down" = "move container to workspace ${wsF2}";
        "${modifier}+Shift+KP_Next" = "move container to workspace ${wsF3}";
        "${modifier}+Shift+KP_Left" = "move container to workspace ${wsF4}";
        "${modifier}+Shift+KP_Begin" = "move container to workspace ${wsF5}";
        "${modifier}+Shift+KP_Right" = "move container to workspace ${wsF6}";
        "${modifier}+Shift+KP_Home" = "move container to workspace ${wsF7}";
        "${modifier}+Shift+KP_Up" = "move container to workspace ${wsF8}";
        "${modifier}+Shift+KP_Prior" = "move container to workspace ${wsF9}";
        "${modifier}+Shift+KP_Insert" = "move container to workspace ${wsF10}";
        # move to next/prev workspace
        "Ctrl+${modifier}+Left " = "workspace prev";
        "Ctrl+${modifier}+Right" = "workspace next";

        ## Layout
        # You can "split" the current object of your focus with
        # $mod+b or $mod+v, for horizontal and vertical splits
        # respectively.
        "${modifier}+b" = "splith";
        "${modifier}+v" = "splitv";
        # Switch the current container between different layout styles
        "${modifier}+comma" = "layout stacking";
        "${modifier}+period" = "layout tabbed";
        "${modifier}+slash" = "layout toggle split";
        # Make the current focus fullscreen
        "${modifier}+f" = "fullscreen";
        # Toggle the current focus between tiling and floating mode
        "${modifier}+Shift+space" = "floating toggle";
        # Swap focus between the tiling area and the floating area
        "${modifier}+tab" = "focus mode_toggle";
        # move focus to the parent container
        "${modifier}+a" = "focus parent";
        "${modifier}+o" = "workspace back_and_forth";

        ## Scratchpad
        # Sway has a "scratchpad", which is a bag of holding for windows.
        # You can send windows there and get them back later.
        # Move the currently focused window to the scratchpad
        "${modifier}+Shift+minus" = "move scratchpad";
        "${modifier}+Shift+KP_Subtract" = "move scratchpad";
        # Show the next scratchpad window or hide the focused scratchpad window.
        # If there are multiple scratchpad windows, this command cycles through them.
        "${modifier}+minus" = "scratchpad show";
        "${modifier}+KP_Subtract" = "scratchpad show";

        ## Audio control
        # TODO: ${pulseaudioLight}/bin/pactl
        "XF86AudioRaiseVolume" =
          "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" =
          "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";

        # TODO: ${mpc_cli}/bin/mpc
        # or playerctl, but need to enable mpris for mpd
        "XF86AudioPlay" = "exec mpc toggle";
        "XF86AudioStop" = "exec mpc stop";
        "XF86AudioPrev" = "exec mpc prev";
        "XF86AudioNext" = "exec mpc next";

        ## Modes
        "${modifier}+r" = "mode resize";
        "${modifier}+Pause" = "mode passthrough";
        "${modifier}+Shift+e" = ''mode "${system}"'';
        "${modifier}+Print" = ''mode "${screenie}"'';
      };

      modes = {
        resize = {
          # up will shrink the containers height
          # down will grow the containers height
          # left will shrink the containers width
          # right will grow the containers width
          "${up}" = "resize shrink height 10px";
          "${down}" = "resize grow height 10px";
          "${left}" = "resize shrink width 10px";
          "${right}" = "resize grow width 10px";
          # ditto, with arrow keys
          Up = "resize shrink height 10px";
          Down = "resize grow height 10px";
          Left = "resize shrink width 10px";
          Right = "resize grow width 10px";
          # return to default mode
          Return = "mode default";
          Escape = "mode default";
        };

        # allows all otherwise-bound shortcuts to be activated (useful when
        # sending to VM or nested Sway instance)
        passthrough = {
          # return to default mode
          Pause = "mode default";
        };

        # set $system System: (l) lock, (e) logout, (s) suspend
        "${system}" = {
          l = "exec swaylock -f -i ${config.my.wallpaper} --scaling fill, mode default";
          e = "exit";
          s = "exec --no-startup-id systemctl suspend, mode default";
          # return to default mode
          Return = "mode default";
          Escape = "mode default";
        };

        # set $screenie (a) area, (m) monitor, (w) window, (A) to clipboard, (M) to clipboard, (W) to clipboard
        "${screenie}" = {
          # capture the specified screen area to clipboard
          a = ''
            exec grim -g "$(slurp)" - \
                | curl --data-binary @- https://paste.rs | echo $(</dev/stdin).jpg \
                | tee -a ~/pasters.log | wl-copy --trim-newline; mode default'';
          # capture the focused monitor to clipboard
          m = ''
            exec grim -o $(swaymsg -t get_outputs \
                | jq -r '.[] | select(.focused) | .name') - \
                | curl --data-binary @- https://paste.rs | echo $(</dev/stdin).jpg \
                | tee -a ~/pasters.log | wl-copy --trim-newline; mode default'';
          # capture the focused window to clipboard
          w = ''
            exec swaymsg -t get_tree \
                | jq -r '.. | (.nodes? // empty)[] | if (.pid and .focused) then select(.pid and .focused) | .rect | "\(.x),\(.y) \(.width)x\(.height)" else (.floating_nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x),\(.y) \(.width)x\(.height)" end' \
                | grim -g - - | curl --data-binary @- https://paste.rs \
                | echo $(</dev/stdin).jpg | tee -a ~/pasters.log \
                | wl-copy --trim-newline; mode default'';
          # capture the specified screen area to clipboard
          "Shift+a" =
            ''exec grim -g "$(slurp)" - | wl-copy -t image/png; mode default'';
          # capture the focused monitor to clipboard
          "Shift+m" = ''
            exec grim -o $(swaymsg -t get_outputs \
                | jq -r '.[] | select(.focused) | .name') - | wl-copy -t image/png; mode default'';
          # capture the focused window to clipboard
          "Shift+w" = ''
            exec swaymsg -t get_tree \
                | jq -r '.. | (.nodes? // empty)[] | if (.pid and .focused) then select(.pid and .focused) | .rect | "(.x),(.y) (.width)x(.height)" else (.floating_nodes? // empty)[] | select(.pid and .visible) | .rect | "(.x),(.y) (.width)x(.height)" end' \
                | grim -g - - | wl-copy -t image/png; mode default'';
          # return to default mode
          Escape = "mode default";
          Return = "mode default";
        };
      };

      window = {
        titlebar = true;

        commands = [
          {
            criteria = { app_id = "firefox"; };
            command = "inhibit_idle fullscreen, layout tabbed";
          }
          {
            criteria = { class = "cantata"; };
            command = "floating enable, border none";
          }
          {
            criteria = { app_id = "pavucontrol"; };
            command = "floating enable";
          }
          {
            criteria = { app_id = "mpv"; };
            command =
              "border none, resize set width 1520 px height 1030 px, move left, inhibit_idle visible";
          }
          {
            criteria = {
              title = "^Emotes.*";
              class = "chatterino";
            };
            command = "floating enable";
          }
          {
            criteria = {
              title = "^Chatterino Settings$";
              class = "chatterino";
            };
            command = "floating enable";
          }
          {
            criteria = { app_id = "python3"; };
            command = "floating enable";
          }
          {
            criteria = { app_id = "Alacritty"; };
            command = "border pixel 2";
          }
          {
            criteria = { app_id = "kitty"; };
            command = "border pixel 2";
          }
          {
            criteria = { instance = "emacs"; };
            command = "border pixel 2";
          }
          {
            criteria = { app_id = "emacs"; };
            command = "border pixel 2";
          }
          {
            criteria = { app_id = "org.qutebrowser.qutebrowser"; };
            command = "border none";
          }
          {
            criteria = { instance = "rofi"; };
            command = "floating enable, border none";
          }
          {
            criteria = {
              app_id = "firefox";
              title = "Picture-in-Picture";
            };
            command = "floating enable, move position 877 450, sticky enable";
          }
          {
            criteria = { workspace = "10"; };
            command = "floating enable";
          }
          {
            criteria = { app_id = "SCRATCHTERM"; };
            command = "move scratchpad, border pixel, opacity 0.95, sticky enable";
          }
          # set opacity to 0 so that we don't see the flicker as a result of being
          # unable to specify alacritty's size in pixels
          {
            criteria = { app_id = "drawfloat"; };
            command = "floating enable, border pixel, opacity 0";
          }
        ];
      };

      assigns = {
        "${ws2}" = [
          { app_id = "mpv"; }
          { class = "chatterino"; }
        ];
      };

      startup = [
        { command = "alacritty --class SCRATCHTERM -e tmux -L scratch"; }
      ];

      bars = [];
    };

    extraConfig = ''
      ## Workspaces
      workspace ${ws1}  output DP-2
      workspace ${ws2}  output DP-2
      workspace ${ws3}  output DP-2
      workspace ${ws4}  output DP-2
      workspace ${ws5}  output DP-2
      workspace ${ws6}  output DP-2
      workspace ${ws7}  output DP-2
      workspace ${ws8}  output DP-2
      workspace ${ws9}  output DP-2
      workspace ${ws10} output DP-2

      workspace ${wsF1}  output HDMI-A-1
      workspace ${wsF2}  output HDMI-A-1
      workspace ${wsF3}  output HDMI-A-1
      workspace ${wsF4}  output HDMI-A-1
      workspace ${wsF5}  output HDMI-A-1
      workspace ${wsF6}  output HDMI-A-1
      workspace ${wsF7}  output HDMI-A-1
      workspace ${wsF8}  output HDMI-A-1
      workspace ${wsF9}  output HDMI-A-1
      workspace ${wsF10} output HDMI-A-1

      seat * hide_cursor 5000

      # TODO: Japanese input stuff
      # set $mode_lang j: japanese; esc: english
      # mode "$mode_lang" {
      #     bindsym j exec ibus engine anthy, mode "default"
      #     bindsym Return exec ibus engine xkb:us::eng, mode "default"
      #     bindsym Escape exec ibus engine xkb:us::eng, mode "default"
      # }
      # bindsym $mod+i mode "$mode_lang"
    '';
  };
}
