{ config, pkgs, lib, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    enableTCPIP = true;
    port = 52022;
    ensureDatabases = [ "tovpp" ];
    ensureUsers = [
      {
        name = "tovpp";
        ensurePermissions = {
          "DATABASE tovpp" = "ALL PRIVILEGES";
        };
      }
    ];
    authentication = ''
      local all all trust
      host tovpp tovpp 0.0.0.0/0 md5
    '';
  };

  networking.firewall.allowedTCPPorts = [
    config.services.postgresql.port
  ];
}
