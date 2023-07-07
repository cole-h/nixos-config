{ config, lib, pkgs, my, ... }:
let
  status = pkgs.writeShellScriptBin "status" ''
    volume="$(${pkgs.pamixer}/bin/pamixer --get-volume)%"
    time="$(${pkgs.coreutils}/bin/date +'%d %B %Y %T')"

    space="$(test "$(zfs list -H | awk '{if ($1 == "apool") print $3}' | numfmt --from=iec)" -lt "$(echo 20G | numfmt --from=iec)" && echo '!! less than 20G left in apool !!')"

    printf "%s  %s  %s  %s\n" "$space" "$music" "$volume" "$time"
  '';

  ## Variables for bindings
  # Logo key
  modifier = "Mod4";
  huh = "Ctrl+Alt+${modifier}";
  meh = "Ctrl+Alt+Shift";
  hyper = "Ctrl+Alt+Shift+${modifier}";
  # Alt key
  meta = "Mod1";
  # Home row direction keys, like vim
  up = "k";
  down = "j";
  left = "h";
  right = "l";

  ## Modes
  system = "(l) lock, (e) logout, (s) suspend";
  screenie = "(A) to clipboard, (M) to clipboard, (W) to clipboard";

  ## Executables
  # term = alacritty;
  term = "${pkgs.wezterm}/bin/wezterm";
  # alacritty' = "${pkgs.alacritty}/bin/alacritty";
  kitty = "${pkgs.kitty}/bin/kitty";
  dmenu = "${pkgs.fuzzel}/bin/fuzzel --dmenu --no-icons --dpi-aware=no --background-color '282828ff' --text-color 'ebdbb2ff' --match-color 'd65d0eff' --selection-color '3c3836ff' --border-color 'd65d0eff'";
  menu = ''
    ${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop \
        --usage-log=${config.xdg.cacheHome}/.j4_history \
        --dmenu="${dmenu}"
  '';

  inherit (my) wallpaper;

  ## Workspaces
  # output HDMI-A-1 (left)
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
  # output DP-1 (right)
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
  home.packages = with pkgs; [
    swaybg
    swayidle
    swaylock-effects
    fuzzel
  ];

  wayland.windowManager.sway = {
    enable = true;

    systemdIntegration = true;
    xwayland = true;
    wrapperFeatures = { gtk = true; };

    extraSessionCommands = ''
      export MOZ_ENABLE_WAYLAND=1
      # export QT_QPA_PLATFORM=wayland
      # export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      # export QT_WAYLAND_FORCE_DPI=physical
      # export SDL_VIDEODRIVER=wayland
      # export GDK_BACKEND=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
      export XDG_CURRENT_DESKTOP=sway

      # export GBM_BACKEND=nvidia-drm
      # export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export WLR_NO_HARDWARE_CURSORS=1 # :sunglassesIGuess:
      # export WLR_DRM_NO_ATOMIC=1
    '';

    # TODO: swayidle+swaylock command
    config = {
      output = {
        "*".bg = "${wallpaper} fit";
        "HDMI-A-1" = {
          resolution = "1920x1080";
          position = "0,180";
          scale = "1";
        };
        "DP-1" = {
          adaptive_sync = "on";
          resolution = "2560x1440@165Hz";
          position = "1920,0";
          scale = "1";
        };
      };

      gaps = {
        inner = 5;
        outer = 5;
        smartGaps = true;
      };

      fonts.size = 10.0;
      # fonts = [ "IPAexGothic 10" "DejaVu Sans Mono 10" ];
      # fonts = [ "IPAexGothic 11" "Iosevka Custom Book Extended 10" ];

      input = {
        "1133:49297:Logitech_G903_LIGHTSPEED_Wireless_Gaming_Mouse_w\/_HERO" = {
          accel_profile = "flat";
          pointer_accel = "0";
        };
        "1133:16519:Logitech_G903_LS" = {
          accel_profile = "flat";
          pointer_accel = "0";
        };
        "22861:20513:YMDK_NP21" = {
          xkb_numlock = "enabled";
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
        "Ctrl+Alt+l" = "exec swaylock --clock --indicator -f -i ${wallpaper} --scaling fill";

        ## Basics
        # start a terminal
        "${modifier}+Return" = "exec ${term}";
        "${modifier}+KP_Enter" = "exec ${term}";
        # "${modifier}+Shift+Return" = "exec ${alacritty'}";
        "${modifier}+Ctrl+Shift+Return" = "exec ${kitty}";
        # kill focused window
        "${modifier}+Shift+q" = "kill";
        # start your launcher
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+m" = "exec rofi -show emoji -normal-window";
        # reload the configuration file
        "${modifier}+Shift+c" = "reload";
        # open file browser
        "${modifier}+e" = "exec ${pkgs.gnome.nautilus}/bin/nautilus";
        # "${modifier}+e" = "exec nautilus";
        # paste to paste.sr.ht
        # "${modifier}+c" = "exec ~/scripts/paste";

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
        "${meh}+1" = "workspace ${wsF1}";
        "${meh}+2" = "workspace ${wsF2}";
        "${meh}+3" = "workspace ${wsF3}";
        "${meh}+4" = "workspace ${wsF4}";
        "${meh}+5" = "workspace ${wsF5}";
        "${meh}+6" = "workspace ${wsF6}";
        "${meh}+7" = "workspace ${wsF7}";
        "${meh}+8" = "workspace ${wsF8}";
        "${meh}+9" = "workspace ${wsF9}";
        "${meh}+0" = "workspace ${wsF10}";
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
        "${hyper}+1" = "move container to workspace ${wsF1}";
        "${hyper}+2" = "move container to workspace ${wsF2}";
        "${hyper}+3" = "move container to workspace ${wsF3}";
        "${hyper}+4" = "move container to workspace ${wsF4}";
        "${hyper}+5" = "move container to workspace ${wsF5}";
        "${hyper}+6" = "move container to workspace ${wsF6}";
        "${hyper}+7" = "move container to workspace ${wsF7}";
        "${hyper}+8" = "move container to workspace ${wsF8}";
        "${hyper}+9" = "move container to workspace ${wsF9}";
        "${hyper}+0" = "move container to workspace ${wsF10}";
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
        "XF86AudioRaiseVolume" =
          "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" =
          "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl prev";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";

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

        # set $system (l) lock, (e) logout, (s) suspend
        "${system}" = {
          l = "exec swaylock --clock --indicator -f -i ${wallpaper} --scaling fill, mode default";
          e = "exec 'swaymsg exit; systemctl --user stop sway-session.target'"; # exit
          s = "exec --no-startup-id systemctl suspend, mode default";
          # return to default mode
          Return = "mode default";
          Escape = "mode default";
        };

        # set $screenie (A) to clipboard, (M) to clipboard, (W) to clipboard
        "${screenie}" = {
          # capture the specified screen area to clipboard
          "Shift+a" = ''
            exec ${pkgs.slurp}/bin/slurp \
              | ${pkgs.grim}/bin/grim -g - - \
              | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png; mode default
          '';
          # capture the focused monitor to clipboard
          "Shift+m" = ''
            exec swaymsg -t get_outputs \
              | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' \
              | tail -1 \
              | ${pkgs.grim}/bin/grim -g - - \
              | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png; mode default
          '';
          # capture the focused window to clipboard
          "Shift+w" = ''
            exec swaymsg -t get_tree \
              | ${pkgs.jq}/bin/jq -r '.. | (.nodes? // empty)[] | if (.pid and .focused) then select(.pid and .focused) | .rect | "\(.x),\(.y) \(.width)x\(.height)" else (.floating_nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x),\(.y) \(.width)x\(.height)" end' \
              | tail -1 \
              | ${pkgs.grim}/bin/grim -g - - \
              | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png; mode default
          '';
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
            command = "floating enable";
          }
          {
            criteria = { app_id = "pavucontrol"; };
            command = "floating enable";
          }
          {
            criteria = { app_id = "mpv"; title = "^twitch.tv/.* - mpv"; };
            command =
              "border none, resize set width 1520 px height 1030 px, move left, inhibit_idle visible";
          }
          {
            criteria = { app_id = "mpv"; };
            command = "border none, inhibit_idle visible";
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
            command = "move scratchpad, border pixel, sticky enable";
          }
          {
            # wezterm displays its configuration errors in a separate terminal,
            # but it inherits the class / app_id, so if it was spawned with
            # app_id SCRATCHTERM, all of the windows it spawns will also go to
            # the scratchpad. Instead, I have some configuration that sets the
            # window title to include the workspace the terminal currently has
            # focused -- move it to the scratchpad if it's in the `scratch`
            # workspace.
            criteria = { app_id = "org\\.wezfurlong\\.wezterm"; title = "^.+\\[scratch\\].+\\(local\\)$"; };
            command = "move scratchpad, sticky enable";
          }
          # set opacity to 0 so that we don't see the flicker as a result of being
          # unable to specify alacritty's size in pixels
          {
            criteria = { app_id = "drawfloat"; };
            command = "floating enable, border pixel, opacity 0";
          }
          {
            criteria = { class = "jetbrains-studio"; };
            command = "floating enable";
          }
          {
            criteria = { app_id = "org.pwmt.zathura"; };
            command = "border pixel";
          }
          {
            criteria = { instance = "pinentry"; };
            command = "sticky enable";
          }
          # {
          #   criteria = { app_id = "org.wezfurlong.wezterm"; };
          #   command = "border pixel 2";
          # }
          {
            criteria = { title = "Firefox — Sharing Indicator"; };
            command = "kill";
          }
        ];
      };

      assigns = {
        "${ws2}" = [
          { title = "twitch.tv/.* - mpv"; }
          { class = "chatterino"; }
          { app_id = "chatterino"; }
        ];
        "${wsF9}" = [
          { class = "ffxiv_dx11.exe"; }
          { class = "xivlauncher.exe"; }
        ];
      };

      startup = [
        # {
        #   command = "${pkgs.cadence}/bin/cadence-session-start --system-start";
        # }
        {
          command = "wezterm start --workspace scratch --always-new-process";
        }
        {
          command = ''
            swayidle -w \
              timeout 900 'swaylock --clock --indicator -f -i ${wallpaper} --scaling fill' \
              timeout 1200 'swaymsg "output * dpms off"' \
                resume 'swaymsg "output * dpms on"' \
              before-sleep 'swaylock --clock --indicator -f -i ${wallpaper} --scaling fill'
          '';
        }
      ];

      # use systemd-controlled waybar unit (see ./default.nix)
      bars = [
        {
          statusCommand = "while ${status}/bin/status; do sleep 0.1; done";
          position = "top";
          # fonts = [ "IPAexGothic 11" "DejaVu Sans Mono 10" ];
          fonts.size = 10.0;
          colors = {
            background = "#1f1f1f";
            # inactiveWorkspace = { background = "#808080"; border = "#808080"; text = "#888888"; };
            # activeWorkspace = { background = "#808080"; border = "#808080"; text = "#ffffff"; };
            # focusedWorkspace = { background = "#0000ff"; border = "#0000ff"; text = "#ffffff"; };
            # urgentWorkspace = { background = "#ff0000"; border = "#ff0000"; text = "#ffffff"; };
          };
          extraConfig = ''
            pango_markup disabled
          '';
        }
      ];
    };

    extraConfig = ''
      ## Workspaces
      workspace ${ws1}  output HDMI-A-1
      workspace ${ws2}  output HDMI-A-1
      workspace ${ws3}  output HDMI-A-1
      workspace ${ws4}  output HDMI-A-1
      workspace ${ws5}  output HDMI-A-1
      workspace ${ws6}  output HDMI-A-1
      workspace ${ws7}  output HDMI-A-1
      workspace ${ws8}  output HDMI-A-1
      workspace ${ws9}  output HDMI-A-1
      workspace ${ws10} output HDMI-A-1

      workspace ${wsF1}  output DP-1
      workspace ${wsF2}  output DP-1
      workspace ${wsF3}  output DP-1
      workspace ${wsF4}  output DP-1
      workspace ${wsF5}  output DP-1
      workspace ${wsF6}  output DP-1
      workspace ${wsF7}  output DP-1
      workspace ${wsF8}  output DP-1
      workspace ${wsF9}  output DP-1
      workspace ${wsF10} output DP-1

      seat * hide_cursor 5000
      seat * keyboard_grouping none
      # seat * xcursor_theme default 24

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
