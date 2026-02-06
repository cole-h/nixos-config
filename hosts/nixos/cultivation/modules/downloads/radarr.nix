{ config, ... }:
{
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
