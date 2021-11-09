{ config, ... }:
{
  age.secrets = {
    scar-key = {
      file = ../../../../secrets/scadrial+scar/zrepl/scar.key;
    };

    scar-crt = {
      file = ../../../../secrets/scadrial+scar/zrepl/scar.crt;
    };

    scadrial-crt = {
      file = ../../../../secrets/scadrial+scar/zrepl/scadrial.crt;
    };

    bpool = {
      file = ../../../../secrets/scadrial+scar/bpool;
    };
  };

  networking.firewall.allowedTCPPorts = [
    8888 # zrepl
  ];

  # Scrub the disk regularly to ensure integrity
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  services.zrepl = {
    enable = true;
    settings = {
      global = {
        logging = [
          {
            type = "syslog";
            level = "info";
            format = "human";
          }
        ];
      };

      jobs = [
        {
          name = "bpool_sink";
          type = "sink";
          root_fs = "bpool/zrepl/sink";
          serve = {
            type = "tls";
            listen = ":8888";
            ca = config.age.secrets.scadrial-crt.path;
            cert = config.age.secrets.scar-crt.path;
            key = config.age.secrets.scar-key.path;
            client_cns = [ "scadrial" ];
          };
        }
      ];
    };
  };
}
