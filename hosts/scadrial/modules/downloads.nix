{ pkgs, config, ... }:
{
  users.groups.downloads.gid = 947;
  users.users.downloads = {
    isSystemUser = true;
    group = "downloads";
    uid = 947;
    inherit (config.services.transmission) home;
    createHome = true;
  };

  users.users.vin.extraGroups = [ "downloads" ];

  services.transmission = {
    enable = true;
    user = "downloads";
    group = "downloads";
    home = "/var/lib/torrent";
    settings = {
      rpc-port = 9091;
      download-dir = "/var/lib/torrent/current";
      rpc-whitelist = "127.0.0.1,192.168.*.*";
      ratio-limit = "0";
      ratio-limit-enabled = "true";
      idle-seeding-limit = "1";
      idle-seeding-limit-enabled = "true";
    };
  };

  services.sonarr = {
    enable = true;
    user = "downloads";
    group = "downloads";
  };

  services.jellyfin = {
    enable = true;
    user = "downloads";
    group = "downloads";
  };

  networking.firewall.allowedTCPPorts = [
    8096 # jellyfin
    8989 # sonarr
    9091 # transmission
    80
  ];

  # NOTE: Should also add rules in pihole so others can connect
  networking.extraHosts = ''
    127.0.0.1 sonarr.local
    127.0.0.1 torrents.local
    127.0.0.1 jellyfin.local
  '';

  services.nginx = {
    enable = true;
    virtualHosts =
      let
        onlyLan = ''
          allow 192.168.1.0/24;
          allow 192.168.122.0/24;
          allow 127.0.0.1;
          deny all;
        '';
      in
      {
        "sonarr.local".locations."/" = {
          proxyPass = "http://127.0.0.1:8989/";
          extraConfig = onlyLan;
        };
        "torrents.local".locations."/" = {
          proxyPass = "http://127.0.0.1:9091/";
          extraConfig = onlyLan;
        };
        "jellyfin.local".locations."/" = {
          proxyPass = "http://127.0.0.1:8096/";
          extraConfig = onlyLan;
        };
      };
  };
}
