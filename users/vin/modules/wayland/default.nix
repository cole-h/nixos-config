{ config, pkgs, ... }:
let
  cursorTheme = "Adwaita";
  cursorSize = 24;
in
{
  imports =
    [
      ./sway.nix # sway config
      ./mako.nix # mako config
      ./alacritty.nix # alacritty config
      # ./waybar.nix # waybar config
      # ./japanese.nix # JP config
    ];

  home.packages = with pkgs; [
    jq # json fiddling
    grim # screenshot
    slurp # select region
    wl-clipboard # clipboard
    alacritty # [drvs]
    kitty # alt terminal as backup
    libnotify # notifications part 2: electric boogaloo
    redshift # blue-light filter; [overlays]
    bemenu # dmenu launcher; [overlays]
    j4-dmenu-desktop # desktop files
    rofi # has rofi-emoji as a plugin; [overlays]
    # TODO: TUI display manager for fanciness so I don't have to `systemctl --user import-environment`
    # https://github.com/meatcar/dots/blob/6acc6d2075eb88b144a7fceb001044edbcac4d93/modules/ly.nix
    # ly
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
      mako = {
        Unit = {
          Description = "mako";
          Documentation = [ "man:mako(1)" ];
          PartOf = [ "sway-session.target" ];
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

      redshift = {
        Unit = {
          Description = "redshift";
          Documentation = [ "man:redshift(1)" ];
          PartOf = [ "sway-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${pkgs.redshift}/bin/redshift -t 6500:3000 -l 38.68:-121.14";
          RestartSec = 3;
          Restart = "always";
        };

        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };
    };
  };
}
