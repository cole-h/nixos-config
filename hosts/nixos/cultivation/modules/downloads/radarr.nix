{ config, ... }:
{
  networking.extraHosts = ''
    127.0.0.1 radarr.local
  '';

  services.nginx.virtualHosts."radarr.local".locations."/" = {
    # TODO: no var for the port
    proxyPass = "http://127.0.0.1:7878/";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "downloads";
    group = "downloads";

    environmentFiles = [
      (builtins.toFile "radarr-env" ''
        RADARR__AUTH__TRUSTCGNATIPADDRESSES=true
      '')
    ];
  };
}
