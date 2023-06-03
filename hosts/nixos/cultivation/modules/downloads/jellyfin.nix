{ pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "downloads";
    group = "downloads";
  };

  networking.extraHosts = ''
    127.0.0.1 jellyfin.local
  '';

  services.nginx.virtualHosts = {
    "jellyfin.local".locations."/" = {
      # https://jellyfin.org/docs/general/networking/index.html
      proxyPass = "http://127.0.0.1:8096/";
    };
  };
}
