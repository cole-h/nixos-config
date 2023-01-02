{ pkgs, config, ... }:
{
  networking.extraHosts = ''
    127.0.0.1 torrents.local
  '';

  # TODO: is there a way to only make it create the path if all its parents exist?
  # systemd.tmpfiles.rules = [
  #   "d ${config.services.qbittorrent.dataDir} 0777 ${config.services.qbittorrent.user} ${config.services.qbittorrent.group} - -"
  # ];

  services.nginx.virtualHosts = {
    "torrents.local".locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.qbittorrent.port}/";
    };
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
