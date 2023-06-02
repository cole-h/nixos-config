{ config, ... }:
{
  networking.extraHosts = ''
    127.0.0.1 sonarr.local
  '';

  services.nginx.virtualHosts."sonarr.local".locations."/" = {
    # TODO: no var for the port
    proxyPass = "http://127.0.0.1:8989/";
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "downloads";
    group = "downloads";
  };
}
