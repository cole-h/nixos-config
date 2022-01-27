{ pkgs, config, ... }:
{
  networking.extraHosts = ''
    127.0.0.1 flood.local
    127.0.0.1 torrents.local
  '';

  systemd.tmpfiles.rules = [
    "d ${config.services.qbittorrent.dataDir} 0777 ${config.services.qbittorrent.user} ${config.services.qbittorrent.group} - -"
    "d ${config.services.flood.downloadDir} 0777 ${config.services.qbittorrent.user} ${config.services.qbittorrent.group} - -"
  ];

  services.nginx.virtualHosts = {
    "flood.local".locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.flood.port}/";
    };
    "torrents.local".locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.qbittorrent.port}/";
    };
  };

  services.flood = {
    enable = false;
    openFirewall = true;
    host = "0.0.0.0";
    port = 50001;
    group = config.services.qbittorrent.group;
    downloadDir = "${config.services.qbittorrent.dataDir}/flood";
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    port = 50000;
    user = "downloads";
    group = "downloads";
    dataDir = "/shares/torrents/qbittorrent";
  };
}
