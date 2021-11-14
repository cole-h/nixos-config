{ pkgs, config, ... }:
let
  sonarrPort = 8989;
  transmissionPort = 9091;
  jellyfinPort = 8096;
in
{
  users.groups.downloads.gid = 947;
  users.users.downloads = {
    isSystemUser = true;
    group = config.users.groups.downloads.name;
    uid = 947;
    inherit (config.containers.downloads.config.services.transmission) home;
    createHome = true;
  };

  users.users.vin.extraGroups = [ "downloads" ];

  networking.firewall.allowedTCPPorts = [
    80 # nginx
  ];

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
          allow 127.0.0.1;
          deny all;
        '';
      in
      {
        "sonarr.local".locations."/" = {
          proxyPass = "http://${config.containers.downloads.hostAddress}:${toString sonarrPort}/";
          extraConfig = onlyLan;
        };
        "torrents.local".locations."/" = {
          proxyPass = "http://${config.containers.downloads.hostAddress}:${toString transmissionPort}/";
          extraConfig = onlyLan;
        };
        "jellyfin.local".locations."/" = {
          proxyPass = "http://${config.containers.downloads.hostAddress}:${toString jellyfinPort}/";
          extraConfig = onlyLan;
        };
      };
  };

  containers.downloads = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.0.1.1";
    localAddress = "10.0.1.2";

    forwardPorts = [
      { containerPort = jellyfinPort; hostPort = jellyfinPort; protocol = "tcp"; }
      { containerPort = sonarrPort; hostPort = sonarrPort; protocol = "tcp"; }
      { containerPort = transmissionPort; hostPort = transmissionPort; protocol = "tcp"; }
    ];

    bindMounts = {
      "jellyfin" = {
        mountPoint = "/var/lib/jellyfin";
        hostPath = "/var/lib/jellyfin";
        isReadOnly = false;
      };
      "sonarr" = {
        mountPoint = "/var/lib/sonarr";
        hostPath = "/var/lib/sonarr";
        isReadOnly = false;
      };
      "torrent" = {
        mountPoint = "/var/lib/torrent";
        hostPath = "/var/lib/torrent";
        isReadOnly = false;
      };
      "media" = {
        mountPoint = "/media";
        hostPath = "/media";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }: {
      users.groups.downloads.gid = 947;
      users.users.downloads = {
        isSystemUser = true;
        group = config.users.groups.downloads.name;
        uid = 947;
        inherit (config.services.transmission) home;
        createHome = true;
      };

      networking.firewall.allowedTCPPorts = [
        jellyfinPort
        sonarrPort
        transmissionPort
      ];

      services.transmission = {
        enable = true;
        user = "downloads";
        group = "downloads";
        home = "/var/lib/torrent";
        settings = {
          rpc-port = transmissionPort;
          rpc-bind-address = "0.0.0.0";
          rpc-whitelist = "127.0.0.1,10.0.*.*";
          download-dir = "${config.services.transmission.home}/current";
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
    };
  };
}
