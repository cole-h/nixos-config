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
    80 # allow
  ];

  # NOTE: Should also add rules in pihole so others can connect
  networking.extraHosts = ''
    127.0.0.1 sonarr.local
    127.0.0.1 torrents.local
  '';

  services.nginx = {
    enable = true;
    virtualHosts =
      let
        onlyLan = ''
          allow 192.168.1.0/24;
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
      };
  };

  ## Seems to take up too many resources (I hear crackling when listening to
  ## music). Maybe the music's fault, but meh. TODO: revisit once on SSD (maybe
  ## because it was on an HDD?)
  # containers.downloads = {
  #   autoStart = true;

  #   config = { config, pkgs, ... }: {
  #     users.users.downloads = { group = "downloads"; uid = 947; };
  #     users.groups.downloads.gid = 947;

  #     services.sonarr = {
  #       enable = true;
  #       user = "downloads";
  #       group = "downloads";
  #     };

  #     services.transmission = {
  #       enable = true;
  #       user = "downloads";
  #       group = "downloads";
  #       home = "/var/lib/torrent";
  #       settings = {
  #         download-dir = "/var/lib/torrent/current";
  #         rpc-whitelist = "127.0.0.1,192.168.*.*";
  #         ratio-limit = "0";
  #         ratio-limit-enabled = "true";
  #         idle-seeding-limit = "1";
  #         idle-seeding-limit-enabled = "true";
  #       };
  #     };
  #   };

  #   forwardPorts = [
  #     { containerPort = 8989; hostPort = 8989; protocol = "tcp"; } # Sonarr
  #     { containerPort = 9091; hostPort = 9091; protocol = "tcp"; } # Transmission
  #   ];

  #   bindMounts = {
  #     "sonarr" = {
  #       mountPoint = "/var/lib/sonarr";
  #       hostPath = "/var/lib/sonarr";
  #       isReadOnly = false;
  #     };
  #     "torrent" = {
  #       mountPoint = "/var/lib/torrent";
  #       hostPath = "/var/lib/torrent";
  #       isReadOnly = false;
  #     };
  #     "media" = {
  #       mountPoint = "/media";
  #       hostPath = "/media";
  #       isReadOnly = false;
  #     };
  #   };
  # };
}
