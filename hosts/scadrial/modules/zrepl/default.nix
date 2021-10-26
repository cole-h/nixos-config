{ config, pkgs, lib, ... }:
{
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
      ];
    };
  };
}
