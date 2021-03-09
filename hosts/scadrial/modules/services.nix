{ config, pkgs, lib, ... }:
{
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
          name = "win10_snap";
          type = "snap";
          filesystems = {
            "rpool/win10" = true;
          };

          snapshotting = {
            type = "periodic";
            interval = "4h";
            prefix = "zrepl_win10_";
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
              regex = "^zrepl_win10_.*";
              grid = lib.concatStringsSep " | " [
                "1x4h"
              ];
            }
          ];
        }
        {
          name = "push_to_bpool";
          type = "push";

          connect = {
            type = "local";
            listener_name = "bpool_sink";
            client_identity = "${config.networking.hostName}";
          };

          filesystems = {
            "apool/ROOT/system<" = true;
            "apool/ROOT/user<" = true;
            "apool/ROOT/user/home/vin/Downloads" = false;
            "rpool/win10" = true;
          };

          send.encrypted = true;

          # if space becomes an issue, uncomment below:
          # replication.protection = {
          #   initial = "guarantee_resumability";
          #   # https://zrepl.github.io/configuration/replication.html#protection-option
          #   # sacrifice resumability in return for the ability to free disk space
          #   incremental = "guarantee_incremental";
          # };

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
        {
          name = "bpool_sink";
          type = "sink";
          root_fs = "bpool/zrepl/sink";
          serve = {
            type = "local";
            listener_name = "bpool_sink";
          };

          # recv = {
          #   properties."inherit" = [
          #     "compression"
          #   ];
          # };
        }
      ];
    };
  };

  systemd.services.zrepl-replicate = {
    description = "Trigger zrepl replication for push_to_bpool";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.zrepl}/bin/zrepl --config /etc/zrepl/zrepl.yml signal wakeup push_to_bpool";
      # already have a unit for this, so why not use it
      ExecStartPre = "systemctl restart zfs-import-bpool.service";
    };
  };

  systemd.timers.zrepl-replicate = {
    description = "Trigger zrepl replication for push_to_bpool";
    requires = [ "zfs-import.target" ];
    wantedBy = [ "timers.target" "local-fs.target" ];
    after = [ "zfs-import-bpool.service" ];
    timerConfig = {
      Unit = "zrepl-replicate.service";
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  # Scrub the disk regularly to ensure integrity
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  # Automount USB
  services.gvfs.enable = true;

  # Hide the "help" message
  # services.mingetty.helpLine = lib.mkForce "";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
  };

  # Necessary for discovering network printers.
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # services.udev.packages for packages with udev rules
  # SUBSYSTEMS=="usb", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="eed2", TAG+="uaccess", RUN{builtin}+="uaccess"
  services.udev.extraRules =
    # Set noop scheduler for zfs partitions
    ''
      KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    '' +
    # YMDK NP21 bootloader permissions (obdev HIDBoot)
    ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05df", TAG+="uaccess", RUN{builtin}+="uaccess"
    '';
}
