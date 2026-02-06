{ config, ... }:
{
  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "downloads";
    group = "downloads";

    environmentFiles = [
      (builtins.toFile "sonarr-env" ''
        SONARR__AUTH__TRUSTCGNATIPADDRESSES=true
      '')
    ];
  };
}
