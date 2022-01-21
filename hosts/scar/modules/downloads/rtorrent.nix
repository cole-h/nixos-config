{ pkgs, config, ... }:
{
  networking.extraHosts = ''
    127.0.0.1 flood.local
  '';

  systemd.tmpfiles.rules = [
    "d ${config.services.rtorrent.downloadDir} 0777 downloads downloads - -"
  ];

  services.nginx.virtualHosts = {
    "flood.local".locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.flood.port}/";
    };
  };

  services.flood = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
    port = 50001;
    group = "downloads";
    inherit (config.services.rtorrent) downloadDir;
  };

  services.rtorrent = {
    enable = true;
    openFirewall = true;
    user = "downloads";
    group = "downloads";
    dataDir = config.users.users.downloads.home;
    downloadDir = "/shares/torrents/download";
    configText = ''
      ## Tracker-less torrent and UDP tracker support
      dht.mode.set = auto
      dht.port.set = 6881
      protocol.pex.set = yes
      trackers.use_udp.set = yes

      ## Other operational settings (check & adapt)
      system.umask.set = 0007

      ## Some additional values and commands
      method.insert = system.startup_time, value|const, (system.time)
      method.insert = d.data_path, simple,\
          "if=(d.is_multi_file),\
              (cat, (d.directory), /),\
              (cat, (d.directory), /, (d.name))"
      method.insert = d.session_file, simple, "cat=(session.path), (d.hash), .torrent"
    '';
  };
}
