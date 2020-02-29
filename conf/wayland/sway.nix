{ config, lib, pkgs, ... }:

let
  # Logo key. Use Mod1 for Alt.
  mod = "Mod4";
  meta = "Mod1";
  # Home row direction keys, like vim
  up = "k";
  down = "j";
  left = "h";
  right = "l";
  # Your preferred terminal emulator
  term = toString ~/scripts/alacritty.sh;
  alacritty = "env RUST_BACKTRACE=1 alacritty";
  menu = "rofi -show drun -show-icons -normal-window";
  wallpaper = toString ./wallpaper.png;
in {
  home.packages = with pkgs; [
    mako # nbtifications
    redshift-wlr # blue-light filter [overlays]
    waybar
    libnotify
    grim
    jq
  ];

  wayland.windowManager.sway = {
    enable = true;

    config = {
      output = {
        "*".bg = "${wallpaper} fit";
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

      fonts = [ "SF Pro Display 11" ];

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

      # Drag floating windows by holding down $mod and left mouse button.
      # Resize them with right mouse button + $mod.
      # Despite the name, also works for non-floating windows.
      # Change normal to inverse to use left mouse button for resizing and right
      # mouse button for dragging.
      floating.modifier = "${mod}";

      keybindings = {
        "Ctrl+Alt+l" = "exec swaylock -f -i ${wallpaper} --scaling fill";

        ## Basics
        # start a terminal
        "${mod}+Return" = "exec ${term}";
        "${mod}+Shift+Return" = "exec ${alacritty}";
        "${mod}+${meta}+Shift+Return" = "exec kitty"; # TODO
        # kill focused window
        "${mod}+Shift+q" = "kill";
        # start your launcher
        "${mod}+d" = "exec $menu";
        "${mod}+m" = "exec rofi -show emoji -normal-window";
        # reload the configuration file
        "${mod}+Shift+c" = "reload";
        # open file browser
        "${mod}+e" = "exec nautilus";
        # open password menu
        "${mod}+p" = "exec ~/scripts/passmenu";
        "${mod}+Shift+p" = "exec ~/scripts/otpmenu";
        # paste to paste.sr.ht
        "${mod}+c" = "exec ~/scripts/paste";

        ## Moving around
        # Move your focus around
        "${mod}+${left}" = "focus left";
        "${mod}+${down}" = "focus down";
        "${mod}+${up}" = "focus up";
        "${mod}+${right}" = "focus right";
        # or use ${mod}+[up|down|left|right]
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";
        # _move_ the focused window with the same, but add Shift
        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${down}" = "move down";
        "${mod}+Shift+${up}" = "move up";
        "${mod}+Shift+${right}" = "move right";
        # ditto, with arrow keys
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        ## Workspaces
        # switch to workspace
        "${mod}+1" = "workspace $ws1";
        "${mod}+2" = "workspace $ws2";
        "${mod}+3" = "workspace $ws3";
        "${mod}+4" = "workspace $ws4";
        "${mod}+5" = "workspace $ws5";
        "${mod}+6" = "workspace $ws6";
        "${mod}+7" = "workspace $ws7";
        "${mod}+8" = "workspace $ws8";
        "${mod}+9" = "workspace $ws9";
        "${mod}+0" = "workspace $ws10";
        "${mod}+F1" = " workspace $wsF1";
        "${mod}+F2" = " workspace $wsF2";
        "${mod}+F3" = " workspace $wsF3";
        "${mod}+F4" = " workspace $wsF4";
        "${mod}+F5" = " workspace $wsF5";
        "${mod}+F6" = " workspace $wsF6";
        "${mod}+F7" = " workspace $wsF7";
        "${mod}+F8" = " workspace $wsF8";
        "${mod}+F9" = " workspace $wsF9";
        "${mod}+F10" = "workspace $wsF10";
        "${mod}+KP_1" = " workspace $wsF1";
        "${mod}+KP_2" = " workspace $wsF2";
        "${mod}+KP_3" = " workspace $wsF3";
        "${mod}+KP_4" = " workspace $wsF4";
        "${mod}+KP_5" = " workspace $wsF5";
        "${mod}+KP_6" = " workspace $wsF6";
        "${mod}+KP_7" = " workspace $wsF7";
        "${mod}+KP_8" = " workspace $wsF8";
        "${mod}+KP_9" = " workspace $wsF9";
        "${mod}+KP_0" = " workspace $wsF10";
        # move focused container to workspace
        "${mod}+Shift+1" = "move container to workspace $ws1";
        "${mod}+Shift+2" = "move container to workspace $ws2";
        "${mod}+Shift+3" = "move container to workspace $ws3";
        "${mod}+Shift+4" = "move container to workspace $ws4";
        "${mod}+Shift+5" = "move container to workspace $ws5";
        "${mod}+Shift+6" = "move container to workspace $ws6";
        "${mod}+Shift+7" = "move container to workspace $ws7";
        "${mod}+Shift+8" = "move container to workspace $ws8";
        "${mod}+Shift+9" = "move container to workspace $ws9";
        "${mod}+Shift+0" = "move container to workspace $ws10";
        "${mod}+Shift+F1" = " move container to workspace $wsF1";
        "${mod}+Shift+F2" = " move container to workspace $wsF2";
        "${mod}+Shift+F3" = " move container to workspace $wsF3";
        "${mod}+Shift+F4" = " move container to workspace $wsF4";
        "${mod}+Shift+F5" = " move container to workspace $wsF5";
        "${mod}+Shift+F6" = " move container to workspace $wsF6";
        "${mod}+Shift+F7" = " move container to workspace $wsF7";
        "${mod}+Shift+F8" = " move container to workspace $wsF8";
        "${mod}+Shift+F9" = " move container to workspace $wsF9";
        "${mod}+Shift+F10" = "move container to workspace $wsF10";
        "${mod}+Shift+KP_End" = "   move container to workspace $wsF1";
        "${mod}+Shift+KP_Down" = "  move container to workspace $wsF2";
        "${mod}+Shift+KP_Next" = "  move container to workspace $wsF3";
        "${mod}+Shift+KP_Left" = "  move container to workspace $wsF4";
        "${mod}+Shift+KP_Begin" = " move container to workspace $wsF5";
        "${mod}+Shift+KP_Right" = " move container to workspace $wsF6";
        "${mod}+Shift+KP_Home" = "  move container to workspace $wsF7";
        "${mod}+Shift+KP_Up" = "    move container to workspace $wsF8";
        "${mod}+Shift+KP_Prior" = " move container to workspace $wsF9";
        "${mod}+Shift+KP_Insert" = "move container to workspace $wsF10";
        # move to next/prev workspace
        "Ctrl+${mod}+Left " = "workspace prev";
        "Ctrl+${mod}+Right" = "workspace next";

        ## Layout stuff
        # You can "split" the current object of your focus with
        # ${mod}+b or $mod+v, for horizontal and vertical splits
        # respectively.
        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";
        # Switch the current container between different layout styles
        "${mod}+comma" = "layout stacking";
        "${mod}+period" = "layout tabbed";
        "${mod}+slash" = "layout toggle split";
        # Make the current focus fullscreen
        "${mod}+f" = "fullscreen";
        # Toggle the current focus between tiling and floating mode
        "${mod}+Shift+space" = "floating toggle";
        # Swap focus between the tiling area and the floating area
        "${mod}+tab" = "focus mode_toggle";
        # move focus to the parent container
        "${mod}+a" = "focus parent";
        "${mod}+o" = "workspace back_and_forth";

        ## Scratchpad
        # Sway has a "scratchpad", which is a bag of holding for windows.
        # You can send windows there and get them back later.
        # Move the currently focused window to the scratchpad
        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+Shift+KP_Subtract" = "move scratchpad";
        # Show the next scratchpad window or hide the focused scratchpad window.
        # If there are multiple scratchpad windows, this command cycles through them.
        "${mod}+minus" = "scratchpad show";
        "${mod}+KP_Subtract" = "scratchpad show";

        ## Audio control
        # TODO: ${pulseaudioFull}/bin/pactl
        "XF86AudioRaiseVolume" =
          "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" =
          "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";

        # TODO: ${mpc_cli}/bin/mpc
        "XF86AudioPlay" = "exec mpc toggle";
        "XF86AudioStop" = "exec mpc stop";
        "XF86AudioPrev" = "exec mpc prev";
        "XF86AudioNext" = "exec mpc next";

        ## Screenshot
        # TODO: packages
        # TODO: make a mode for both paste.rs and to clipboard screenshots
        # capture all screens to clipboard
        "Print" = "exec grim - | wl-copy -t image/png";
        # capture the specified screen area to clipboard
        "${mod}+Print" = ''exec grim -g "$(slurp)" - | wl-copy -t image/png'';
        # capture the focused monitor to clipboard
        "Shift+${mod}+Print" = ''
          exec grim -o $(swaymsg -t get_outputs \
                  | jq -r '.[] | select(.focused) | .name') - | wl-copy -t image/png'';
        # capture the focused window to clipboard
        "Ctrl+Shift+Print" = ''
          exec swaymsg -t get_tree \
                  | jq -r '.. | (.nodes? // empty)[] | if (.pid and .focused) then select(.pid and .focused) | .rect | "(.x),(.y) (.width)x(.height)" else (.floating_nodes? // empty)[] | select(.pid and .visible) | .rect | "(.x),(.y) (.width)x(.height)" end' \
                  | grim -g - - | wl-copy -t image/png'';
      };

      window.commands = [
        {
          criteria = { app_id = "keepassxc"; };
          command = "move scratchpad";
        }
        {
          criteria = { app_id = "firefox"; };
          command = "inhibit_idle fullscreen, layout tabbed";
        }
        {
          criteria = { app_id = "cantata"; };
          command = "floating enable, border none";
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
          command = "floating enable, border none";
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
        # {
        #   criteria = { title = "^vlauncher$"; };
        #   command = " floating enable, border none";
        # }
        # {
        #   criteria = { title = "float"; };
        #   command = "floating enable";
        # }
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
          command = "move scratchpad, border pixel, opacity 0.95";
        }
        # set opacity to 0 so that we don't see the flicker as a result of being
        # unable to specify exact size in pixels
        {
          criteria = { app_id = "drawfloat"; };
          command = "floating enable, border pixel, opacity 0";
        }
      ];

      assigns = {
        "$ws2" = [{
          app_id = "mpv";
          class = "chatterino";
        }];
      };

      startup = [
        {
          command =
            "mako --default-timeout 5000"; # TODO: make a systemd user service
        }
        # { command = "ibus-daemon -xrd"; }
        # { command = "cadence-session-start --system-start"; }
        {
          # TODO: wat do
          command = "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1";
        }
        { command = "sleep 1 && systemctl restart --user redshift"; }
      ];

      bars = [
        #
        { command = "${pkgs.waybar}/bin/waybar"; }
      ];
    };

    extraConfig = ''
      set $ws1  1
      set $ws2  2
      set $ws3  3
      set $ws4  4
      set $ws5  5
      set $ws6  6
      set $ws7  7
      set $ws8  8
      set $ws9  9
      set $ws10 10

      set $wsF1  11
      set $wsF2  12
      set $wsF3  13
      set $wsF4  14
      set $wsF5  15
      set $wsF6  16
      set $wsF7  17
      set $wsF8  18
      set $wsF9  19
      set $wsF10 20

      workspace $ws1  output DP-2
      workspace $ws2  output DP-2
      workspace $ws3  output DP-2
      workspace $ws4  output DP-2
      workspace $ws5  output DP-2
      workspace $ws6  output DP-2
      workspace $ws7  output DP-2
      workspace $ws8  output DP-2
      workspace $ws9  output DP-2
      workspace $ws10 output DP-2

      workspace $wsF1  output HDMI-A-1
      workspace $wsF2  output HDMI-A-1
      workspace $wsF3  output HDMI-A-1
      workspace $wsF4  output HDMI-A-1
      workspace $wsF5  output HDMI-A-1
      workspace $wsF6  output HDMI-A-1
      workspace $wsF7  output HDMI-A-1
      workspace $wsF8  output HDMI-A-1
      workspace $wsF9  output HDMI-A-1
      workspace $wsF10 output HDMI-A-1

      seat * hide_cursor 5000

      ## Modes
      # TODO: move to modes and keybindings sections
      # Resizing containers:
      #
      mode "resize" {
          # left will shrink the containers width
          # right will grow the containers width
          # up will shrink the containers height
          # down will grow the containers height
          bindsym ${left} resize shrink width 10px
          bindsym ${down} resize grow height 10px
          bindsym ${up} resize shrink height 10px
          bindsym ${right} resize grow width 10px

          # ditto, with arrow keys
          bindsym Left resize shrink width 10px
          bindsym Down resize grow height 10px
          bindsym Up resize shrink height 10px
          bindsym Right resize grow width 10px

          # return to default mode
          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      bindsym ${mod}+r mode "resize"

      set $mode_lang j: japanese; esc: english
      mode "$mode_lang" {
          bindsym j exec ibus engine anthy, mode "default"
          bindsym Return exec ibus engine xkb:us::eng, mode "default"
          bindsym Escape exec ibus engine xkb:us::eng, mode "default"
      }
      bindsym ${mod}+i mode "$mode_lang"

      set $mode_system System: (l) lock, (e) logout, (s) suspend
      #(r) reboot, (S) shutdown, (R) UEFI
      mode "$mode_system" {
          bindsym l exec swaylock -f -i $wallpaper --scaling fill, mode "default"
          bindsym e exit
          bindsym s exec --no-startup-id systemctl suspend, mode "default"

          # return to default mode
          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      bindsym ${mod}+Shift+e mode "$mode_system"

      # allows all otherwise-bound shortcuts to be activated (useful when sending
      # to VM or nested Sway instance)
      set $passthrough passthrough
      mode "$passthrough" {
          bindsym Pause mode "default"
      }
      bindsym ${mod}+Pause mode $passthrough

      # TODO: wl-copy, tee, curl, grim, jq, swaymsg
      set $screenie (a) area, (m) monitor, (w) window, (A) to clipboard, (M) to clipboard, (W) to clipboard
      mode "$screenie" {
          # capture the specified screen area to clipboard
          bindsym a exec grim -g "$(slurp)" - \
              | curl --data-binary @- https://paste.rs | echo $(</dev/stdin).jpg \
              | tee -a /tmp/pasters.log | wl-copy --trim-newline; mode "default"
          # capture the focused monitor to clipboard
          bindsym m exec grim -o $(swaymsg -t get_outputs \
              | jq -r '.[] | select(.focused) | .name') - \
              | curl --data-binary @- https://paste.rs | echo $(</dev/stdin).jpg \
              | tee -a /tmp/pasters.log | wl-copy --trim-newline; mode "default"
          # capture the focused window to clipboard
          bindsym w exec swaymsg -t get_tree \
              | jq -r '.. | (.nodes? // empty)[] | if (.pid and .focused) then select(.pid and .focused) | .rect | "\(.x),\(.y) \(.width)x\(.height)" else (.floating_nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x),\(.y) \(.width)x\(.height)" end' \
              | grim -g - - | curl --data-binary @- https://paste.rs \
              | echo $(</dev/stdin).jpg | tee -a /tmp/pasters.log \
              | wl-copy --trim-newline; mode "default"

          bindsym Escape mode "default"
          bindsym Return mode "default"
      }
      bindsym ${mod}+s mode "$screenie"
    '';
  };
}
