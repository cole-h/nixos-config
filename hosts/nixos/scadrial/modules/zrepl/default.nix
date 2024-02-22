{ config, pkgs, lib, secretsPath, ... }:
{
  age.secrets = {
    scadrial-key = {
      file = "${secretsPath}/scadrial+cultivation/zrepl/scadrial.key";
    };

    scadrial-crt = {
      file = "${secretsPath}/scadrial+cultivation/zrepl/scadrial.crt";
    };

    cultivation-crt = {
      file = "${secretsPath}/scadrial+cultivation/zrepl/cultivation.crt";
    };
  };

  networking.extraHosts = ''
    192.168.1.55 cultivation.local
  '';

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
                "12x5m"
                "16x15m"
                "6x4h"
                "7x1d"
                "12x1w"
              ];
            }
          ];
        }
        {
          name = "scadrial_to_cultivation";
          type = "push";

          connect = {
            type = "tls";
            address = "cultivation.local:8888";
            ca = config.age.secrets.cultivation-crt.path;
            cert = config.age.secrets.scadrial-crt.path;
            key = config.age.secrets.scadrial-key.path;
            server_cn = "cultivation";
            dial_timeout = "60s";
          };

          filesystems = {
            "apool/ROOT/system<" = true;
            "apool/ROOT/user<" = true;
            "apool/ROOT/user/home/vin/Downloads" = false;
            "apool/ROOT/user/home/vin/Games" = false;
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

  systemd.services.zrepl-replicate = {
    description = "Trigger zrepl replication for push_to_bpool";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.zrepl}/bin/zrepl --config /etc/zrepl/zrepl.yml signal wakeup scadrial_to_cultivation";
      Restart = "on-failure";
    };
  };

  systemd.timers.zrepl-replicate = {
    description = "Trigger zrepl replication for scadrial_to_cultivation";
    wantedBy = [ "timers.target" ];
    after = [ "default.target" "network.target" "zrepl.service" "tailscaled.service" ];
    timerConfig = {
      Unit = "zrepl-replicate.service";
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  # I don't care how it died, it must live.
  systemd.services.zrepl = {
    # Removes the limiter on number of restarts -- will continue to restart
    # until it succeeds.
    unitConfig.StartLimitIntervalSec = lib.mkForce 0;
    serviceConfig.Restart = lib.mkForce "always";
  };
}
