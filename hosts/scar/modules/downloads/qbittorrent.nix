{ config, lib, pkgs, ... }:
let
  cfg = config.services.qbittorrent;
  pkg = pkgs.qbittorrent-nox;

  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
in
{
  options.services.qbittorrent = {
    enable = mkEnableOption "qbittorrent";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
      description = ''
        The directory where qBittorrent will create files.
      '';
    };

    configDir = mkOption {
      type = types.path;
      default = "${cfg.dataDir}/.config";
      description = ''
        The directory where qBittorrent will store its configuration.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        User account under which qBittorrent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = ''
        Group under which qBittorrent runs.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = ''
        qBittorrent web UI port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Allow qBittorrent's ports to accept connections from the outside network.
      '';
    };

    openFilesLimit = mkOption {
      default = 4096;
      description = ''
        Number of files to allow qBittorrent to open.
      '';
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkg ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    systemd.services.qbittorrent = {
      after = [ "network.target" ];
      description = "qBittorrent Daemon";
      wantedBy = [ "multi-user.target" ];
      path = [ pkg ];
      serviceConfig = {
        ExecStart = ''
          ${pkg}/bin/qbittorrent-nox \
            --profile=${cfg.configDir} \
            --webui-port=${toString cfg.port}
        '';
        Restart = "on-success";
        User = cfg.user;
        Group = cfg.group;
        UMask = "0002";
        LimitNOFILE = cfg.openFilesLimit;
      };
    };

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        description = "qBittorrent Daemon user";
      };
    };

    users.groups = mkIf (cfg.group == "qbittorrent") {
      qbittorrent = { };
    };
  };
}
