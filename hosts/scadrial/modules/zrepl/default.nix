{ config, pkgs, lib, ... }:
{
  age.secrets = {
    scadrial-key = {
      file = ../../../../secrets/scadrial+scar/zrepl/scadrial.key;
    };

    scadrial-crt = {
      file = ../../../../secrets/scadrial+scar/zrepl/scadrial.crt;
    };

    scar-crt = {
      file = ../../../../secrets/scadrial+scar/zrepl/scar.crt;
    };
  };

  # ZFS snapshotting for stuff I want backed up.
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
          name = "sys_user_snap";
          type = "snap";
          filesystems = {
            "apool/ROOT/system<" = true;
            "apool/ROOT/user<" = true;
          };

          snapshotting = {
            type = "periodic";
            interval = "5m";
            prefix = "zrepl_snap_";
          };

          pruning.keep = [
            {
              # keep all non-zrepl snapshots
              type = "regex";
              negate = true;
              regex = "^zrepl_.*";
            }
            {
              type = "grid";
              regex = "^zrepl_snap_.*";
              grid = lib.concatStringsSep " | " [
                "3x5m"
                "16x15m"
                "6x4h"
                "7x1d"
                "4x1w"
                "52x1w"
              ];
            }
          ];
        }
        {
          name = "scadrial_to_scar";
          type = "push";

          connect = {
            type = "tls";
            address = "scar.local:8888";
            ca = config.age.secrets.scar-crt.path;
            cert = config.age.secrets.scadrial-crt.path;
            key = config.age.secrets.scadrial-key.path;
            server_cn = "scar";
          };

          filesystems = {
            "apool/ROOT/system<" = true;
            "apool/ROOT/user<" = true;
            "apool/ROOT/user/home/vin/Downloads" = false;
          };

          send.encrypted = true;

          # snapshotting is handled by snap jobs
          snapshotting.type = "manual";

          pruning = {
            # no-op prune rule on sender (keep all snapshots), snap jobs
            # handle this
            keep_sender = [
              {
                type = "regex";
                regex = ".*";
              }
            ];

            keep_receiver = [
              {
                # keep all non-zrepl snapshots
                type = "regex";
                negate = true;
                regex = "^zrepl_.*";
              }
              {
                type = "grid";
                regex = "^zrepl_snap_.*";
                grid = lib.concatStringsSep " | " [
                  "1x1h(keep=all)"
                  "24x1h"
                  "365x1d"
                ];
              }
              {
                type = "grid";
                regex = "^zrepl_win10_.*";
                grid = lib.concatStringsSep " | " [
                  "7x1d(keep=all)"
                  "4x1w"
                ];
              }
            ];
          };
        }
      ];
    };
  };
}
