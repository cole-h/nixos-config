{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    cantata # gui
    ncmpcpp # tui
  ];

  # TODO: cantata settings maybe?
  services.mpd = rec {
    enable = true;

    dataDir = "${config.xdg.configHome}/mpd";
    musicDirectory = "${config.home.homeDirectory}/Music";
    playlistDirectory = "${dataDir}/playlists";
    dbFile = "${dataDir}/database";
    network.listenAddress = "127.0.0.1";

    extraConfig = ''
      log_file "${dataDir}/log"
      pid_file "${dataDir}/pid"

      group "audio"

      auto_update "yes"

      zeroconf_enabled "yes"
      zeroconf_name "MPD @ Scadrial"

      # input {
      #     plugin "curl"
      # }

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

  systemd.user.services.mpd = {
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
      RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
      RestrictNamespaces = "yes";
      # The logfile can grow large... After ~5 months, it was roughly 1.5GiB
      ExecStopPost = "echo > ${config.services.mpd.dataDir}/log";
    };
  };
}
