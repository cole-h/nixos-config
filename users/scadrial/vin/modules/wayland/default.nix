{ config, pkgs, ... }:
let
  cursorTheme = config.home.pointerCursor.name;
  cursorSize = config.home.pointerCursor.size;
in
{
  imports =
    [
      ./sway.nix # sway config
      ./mako.nix # mako config
    ];

  home.packages = with pkgs; [
    jq # json fiddling
    grim # screenshot
    slurp # select region
    wl-clipboard # clipboard
    wezterm # terminal again
    kitty # alt terminal as backup
    libnotify # notifications part 2: electric boogaloo
    wlsunset # blue-light filter
    j4-dmenu-desktop # desktop files
    rofi # has rofi-emoji as a plugin; [overlays]
  ];

  gtk = {
    enable = true;

    gtk2.extraConfig = ''
      gtk-cursor-theme-name="${cursorTheme}"
      gtk-cursor-theme-size=${toString cursorSize}
    '';

    gtk3.extraConfig = {
      "gtk-cursor-theme-name" = cursorTheme;
      "gtk-cursor-theme-size" = cursorSize;
    };
  };

  qt = {
    enable = false;
  };

  systemd.user = {
    services = {
      polkit = {
        Unit = {
          Description = "polkit-gnome";
          Documentation = [ "man:polkit(8)" ];
          PartOf = [ "sway-session.target" ];
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

      wlsunset = {
        Unit = {
          Description = "wlsunset";
          Documentation = [ "man:wlsunset(1)" ];
          PartOf = [ "sway-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.wlsunset}/bin/wlsunset -T 6500 -t 3000 -l 38.68 -L -121.14";
          RestartSec = 3;
          Restart = "always";
        };

        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };

      # TODO: maybe this shouldn't be part of sway so that it can be used over
      # ssh?
      gnome-keyring-daemon = {
        Unit = {
          Description = "gnome-keyring-daemon";
          Documentation = [ "man:gnome-keyring-daemon(1)" ];
          PartOf = [ "sway-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --start --foreground";
          ExecReload = "/run/wrappers/bin/gnome-keyring-daemon --replace --foreground";
          RestartSec = 3;
          Restart = "on-abort";
        };

        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };
    };
  };
}
