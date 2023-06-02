{ config, ... }:
{
  age.secrets = {
    /*
      cd $(mktemp -d); begin; set name $hostname; openssl req -x509 -sha256 -nodes \
        -newkey rsa:4096 \
        -days 365 \
        -keyout $name.key \
        -out $name.crt -addext "subjectAltName = DNS:$name" -subj "/CN=$name"; end
    */
    cultivation-key = {
      file = ../../../../secrets/scadrial+cultivation/zrepl/cultivation.key;
    };

    cultivation-crt = {
      file = ../../../../secrets/scadrial+cultivation/zrepl/cultivation.crt;
    };

    scadrial-crt = {
      file = ../../../../secrets/scadrial+cultivation/zrepl/scadrial.crt;
    };

    bpool = {
      file = ../../../../secrets/scadrial+cultivation/bpool;
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
            cert = config.age.secrets.cultivation-crt.path;
            key = config.age.secrets.cultivation-key.path;
            client_cns = [ "scadrial" ];
          };
        }
      ];
    };
  };
}

