{ super, config, lib, pkgs, ... }:

let
  spotifyd-change = pkgs.writeScript "spotifyd-change" ''
    #!${pkgs.fish}/bin/fish

    set meta (${pkgs.playerctl}/bin/playerctl -p spotifyd metadata | string join '\n')

    set trackid (echo $meta | string split '\n' | ${pkgs.gawk}/bin/awk '/trackid\s/ {for(i=3;i<=NF;++i)printf $i FS}' | string trim)
    test $trackid = (${pkgs.coreutils}/bin/cat /tmp/spotifyd-track) && exit
    echo $trackid > /tmp/spotifyd-track

    set title (echo $meta | string split '\n' | ${pkgs.gawk}/bin/awk '/title\s/ {for(i=3;i<=NF;++i)printf $i FS}' | string trim)
    set artist (echo $meta | string split '\n' | ${pkgs.gawk}/bin/awk '!found && /artist\s/ {for(i=3;i<=NF;++i)printf $i FS; found=1}' | string trim)
    set album (echo $meta | string split '\n' | ${pkgs.gawk}/bin/awk '/album\s/ {for(i=3;i<=NF;++i)printf $i FS}' | string trim)
    set art (echo $meta | string split '\n' | ${pkgs.gawk}/bin/awk '/artUrl\s/ {for(i=3;i<=NF;++i)printf $i FS}' | string trim)

    set artfile (${pkgs.coreutils}/bin/mktemp -t spotifyd.XXXXXXXXXX)
    function finish --on-event fish_exit
      ${pkgs.coreutils}/bin/rm -f $artfile
    end

    ${pkgs.curl}/bin/curl -ksSL "$art" -o "$artfile"

    ${pkgs.libnotify}/bin/notify-send "$title" "$artist • $album" --icon="$artfile"
  '';
in
{
  home.packages = with pkgs; [
    cantata # gui
    ncmpcpp # tui
    playerctl
    spotify
  ];

  systemd.user.services."spotifyd" = {
    Unit.After = [ "suspend.target" ];
    Install.WantedBy = [ "suspend.target" "default.target" ];
    Service.Restart = "always";
  };

  services.spotifyd = {
    # enable = true;
    package = pkgs.spotifyd.override { withMpris = true; };

    settings.global = {
      username = "cole.e.helbling@outlook.com";
      password_cmd = "cat ${super.age.secrets.spotifyd.path}";
      use_mpris = true;
      backend = "pulseaudio";
      device_name = "spotifyd";
      bitrate = 320;
      volume_normalisation = true;
      device_type = "speaker";
      on_song_change_hook = spotifyd-change;
      autoplay = true;
    };
  };

  services = {
    mpd = rec {
      # enable = true;

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

    # mpdris2 = {
    #   enable = true;
    #   notifications = true;
    # };
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

  # XXX: super duper ultra hack to make my FiiO K3 DAC not suspend when
  # it's not playing audio...
  systemd.user.services."fiio-k3-hack" = {
    Install = {
      WantedBy = [ "pipewire-pulse.service" ];
    };
    Service = {
      ExecStart =
        let
          script = pkgs.writeShellScript "fiio-k3-hack" ''
            ${pkgs.coreutils}/bin/sleep infinity | ${pkgs.pulseaudio}/bin/pacat -v
          '';
        in
        toString script;
    };
    Unit = {
      After = [ "pipewire-pulse.service" ];
      Requires = [ "pipewire-pulse.service" ];
    };
  };
}
