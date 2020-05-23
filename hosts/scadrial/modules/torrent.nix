{ pkgs, config, ... }:

{
  users.groups.downloads.gid = 947;
  users.users.downloads = {
    group = "downloads";
    uid = 947;
    inherit (config.services.transmission) home;
    createHome = true;
  };

  users.users.vin.extraGroups = [ "downloads" ];

  # http://localhost:9091/
  services.transmission = {
    enable = true;
    user = "downloads";
    group = "downloads";
    home = "/var/lib/torrent";
    settings = {
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

  networking.firewall.allowedTCPPorts = [
    8989 # sonarr
    9091 # transmission
  ];

  # services.nginx = {
  #   enable = true;
  #   virtualHosts =
  #     let
  #       all = ''
  #         allow all;
  #       '';
  #       onlyLan = ''
  #         allow 192.168.1.0/24;
  #         deny all;
  #       '';
  #     in
  #     {
  #       "localhost".locations = {
  #         "/sonarr/" = {
  #           proxyPass = "http://127.0.0.1:8989";
  #           # extraConfig = onlyLan;
  #         };
  #         "/torrents/" = {
  #           proxyPass = "http://127.0.0.1:9091";
  #           # extraConfig = onlyLan;
  #         };
  #       };
  #     };
  # };
}
