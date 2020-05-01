{ config, pkgs, ... }:

# TODO: patchShebangs scripts/*.sh?
{
  imports = [
    ./sway.nix # sway config
    ./waybar.nix # waybar config
    # ./japanese.nix # JP config
  ];

  home.packages = with pkgs; [
    jq # json fiddling
    grim # screenshot
    slurp # select region
    wl-clipboard # clipboard
    alacritty # [drvs]
    kitty # alt terminal as backup
    mako # notifications
    libnotify # notifications part 2: electric boogaloo
    redshift-wlr # blue-light filter; [overlays]
    bemenu # dmenu launcher; [overlays]
    j4-dmenu-desktop # desktop files
    rofi # has rofi-emoji as a plugin; [overlays]
    # TODO: TUI display manager for fanciness so I don't have to `systemctl --user import-environment`
    # ly
  ];

  xdg.configFile = {
    # ref: https://github.com/lovesegfault/nix-config/blob/03c4b9d9a01ca5439736c6f0f4b762b900aaddf7/users/bemeurer/sway/mako.nix
    # TODO: verify I don't need that icon stuff on NixOS
    "mako/config".text = ''
      layer=overlay
      anchor=top-center
      width=400
      default-timeout=15000
    '';
  };

  systemd.user = {
    services = {
      mako = {
        Unit = {
          Description = "mako";
          Documentation = [ "man:mako(1)" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.mako}/bin/mako";
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
          ExecStart = "${pkgs.redshift-wlr}/bin/redshift -t 6500:3000 -l 38.68:-121.14";
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
            "SSH_AUTH_SOCK=%t/gnupg/S.gpg-agent.ssh"
          ];

          ExecStart = "${config.wayland.windowManager.sway.package}/bin/sway";
          ExecStop = "${config.wayland.windowManager.sway.package}/bin/swaymsg exit";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      # TODO: "pam_authenticate failed: authentication information unavailable"
      # swayidle = {
      #   Unit = {
      #     Description = "swayidle";
      #     Documentation = [ "man:swayidle(1)" ];
      #     PartOf = [ "graphical-session.target" ];
      #   };

      #   Service = {
      #     Type = "simple";
      #     ExecStart = ''
      #       ${pkgs.swayidle}/bin/swayidle -w \
      #         timeout 1200 '${pkgs.swaylock}/bin/swaylock -f -i ${config.my.wallpaper} --scaling fill' \
      #         timeout 1500 'swaymsg "output * dpms off"' \
      #           resume 'swaymsg "output * dpms on"' \
      #         before-sleep '${pkgs.swaylock}/bin/swaylock -f -i ${config.my.wallpaper} --scaling fill'
      #     '';
      #     RestartSec = 3;
      #     Restart = "always";
      #   };

      #   Install = {
      #     WantedBy = [ "sway-session.target" ];
      #   };
      # };

      # waybar = {
      #   Unit = {
      #     Description = "waybar";
      #     Documentation = [ "https://github.com/Alexays/Waybar/wiki" ];
      #     PartOf = [ "graphical-session.target" ];
      #     # Wait on both in order to inherit SWAYSOCK, etc
      #     # After = [ "sway-session.target" "sway.service" ];
      #     Requires = [ "sway-session.target" "sway.service" ];
      #   };

      #   Service = {
      #     Type = "simple";
      #     ExecStart = "${pkgs.waybar}/bin/waybar";
      #     # RestartSec = 1;
      #     Restart = "always";
      #   };

      #   Install = {
      #     WantedBy = [ "sway-session.target" ];
      #   };
      # };
    };
  };
}
