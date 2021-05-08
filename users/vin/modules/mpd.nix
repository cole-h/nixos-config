{ super, config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    cantata # gui
    ncmpcpp # tui
    playerctl
  ];

  services.spotifyd = {
    enable = true;
    package = pkgs.spotifyd.override { withMpris = true; };

    settings.global = {
      username = "cole.e.helbling@outlook.com";
      password_cmd = "cat ${super.age.secrets.spotifyd.path}";
      use_mpris = true;
      backend = "pulseaudio";
      device_name = "spotifyd";
      bitrate = 320;
      volume_normalisation = true;
      normalisation_pregain = -10;
      device_type = "speaker";
    };
  };

  services = {
    mpd = rec {
      enable = true;

      dataDir = "${config.xdg.configHome}/mpd";
      musicDirectory = "${config.home.homeDirectory}/Music";
      playlistDirectory = "${dataDir}/playlists";
      dbFile = "${dataDir}/database";
      network.listenAddress = "127.0.0.1";

      extraConfig = ''
        log_file "syslog"

        group "audio"

        auto_update "yes"

        zeroconf_enabled "yes"
        zeroconf_name "MPD @ Scadrial"

        input {
                enabled "no"
                plugin "qobuz"
        }

        input {
                enabled "no"
                plugin "tidal"
        }

        audio_output {
            type "pulse"
            name "My Pulse Output"
            mixer_type "software"
        }

        replaygain "auto"
        replaygain_limit "yes"
        volume_normalization "yes"
      '';
    };

    mpdris2 = {
      enable = true;
      notifications = true;
    };
  };

  systemd.user.services."mpd" = {
    Unit = { Documentation = "man:mpd(1) man:mpd.conf(5)"; };
    Service = {
      # allow MPD to use real-time priority 50
      LimitRTPRIO = 50;
      LimitRTTIME = "infinity";
      # disallow writing to /usr, /bin, /sbin, ...
      ProtectSystem = "yes";
      # more paranoid security settings
      NoNewPrivileges = "yes";
      ProtectControlGroups = "yes";
      # AF_NETLINK is required by libsmbclient, or it will exit() .. *sigh*
      RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
      RestrictNamespaces = "yes";
    };
  };
}
