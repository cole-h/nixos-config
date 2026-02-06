{ pkgs, config, ... }:
{
  # TODO: is there a way to only make it create the path if all its parents exist?
  # systemd.tmpfiles.rules = [
  #   "d ${config.services.qbittorrent.dataDir} 0777 ${config.services.qbittorrent.user} ${config.services.qbittorrent.group} - -"
  # ];

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = 50000;
    user = "downloads";
    group = "downloads";
    profileDir = "/shares/torrents/qbittorrent/.config";
  };
}
