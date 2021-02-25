{ config, pkgs, ... }:
{
  users.users.ofborg = {
    isSystemUser = true;
    description = "Account for all things ofborg";
    extraGroups = [ "keys" ];
  };

  age.secrets = {
    wg-borg-psk = {
      owner = config.users.users.ofborg.name;
      file = ./psk;
    };

    wg-borg-priv = {
      owner = config.users.users.ofborg.name;
      file = ./priv;
    };

    wg-borg-setup = {
      mode = "0500";
      owner = config.users.users.ofborg.name;
      file = ./borg-setup.sh;
    };

    wg-borg-teardown = {
      mode = "0500";
      owner = config.users.users.ofborg.name;
      file = ./borg-teardown.sh;
    };

    borg-cert = {
      owner = config.users.users.vin.name;
      file = ./cert;
    };
  };

  systemd.paths."wireguard-borg" = {
    description = "WireGuard for ofborg infra -- Secrets";
    requiredBy = [ "wireguard-borg.service" ];
    before = [ "wireguard-borg.service" ];

    pathConfig = {
      PathExists = [
        config.age.secrets.wg-borg-priv.path
        config.age.secrets.wg-borg-psk.path
        config.age.secrets.wg-borg-setup.path
        config.age.secrets.wg-borg-teardown.path
      ];
    };
  };

  systemd.services."wireguard-borg" = {
    description = "WireGuard for ofborg infra";
    requires = [ "network-online.target" ];
    after = [ "network.target" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment.WG_ENDPOINT_RESOLUTION_RETRIES = "infinity";
    environment.PRIV_FILE = config.age.secrets.wg-borg-priv.path;
    environment.PSK_FILE = config.age.secrets.wg-borg-psk.path;
    path = with pkgs; [
      iproute
      wireguard-tools
      bash # scripts use #!/usr/bin/env bash
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = config.age.secrets.wg-borg-setup.path;
      ExecStopPost = config.age.secrets.wg-borg-teardown.path;
      User = config.users.users.ofborg.name;
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ]; # required for wg(1) functionality
      AmbientCapabilities = [ "CAP_NET_ADMIN" ]; # ^

      # Hardening
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_NETLINK"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallErrorNumber = "EPERM";
      SystemCallFilter = [
        "~@chown"
        "~@cpu-emulation"
        "~@debug"
        "~@keyring"
        "~@memlock"
        "~@module"
        "~@mount"
        "~@obsolete"
        "~@privileged"
        "~@resources"
        "~@setuid"
      ];
      UMask = "0077";
    };
  };
}
