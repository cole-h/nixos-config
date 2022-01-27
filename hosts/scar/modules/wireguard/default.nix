{ config, pkgs, ... }:

{
  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = builtins.attrNames config.networking.wireguard.interfaces;
  networking.firewall.allowedUDPPorts =
    map
      (i: config.networking.wireguard.interfaces.${i}.listenPort)
      (builtins.attrNames config.networking.wireguard.interfaces);

  age.secrets = {
    wg0-priv = {
      file = ./priv;
    };

    wg0-psk = {
      file = ./psk;
    };

    duckdns = {
      file = ./duckdns;
    };
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.0.0.1/24" ];
      listenPort = 1194;
      privateKeyFile = config.age.secrets.wg0-priv.path;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
      '';

      peers = [
        {
          # Hathsin
          publicKey = "Nx3B53tK74nc909S0gM0sozUMZOVpAmkqsvyEo6VWSE=";
          presharedKeyFile = config.age.secrets.wg0-psk.path;
          allowedIPs = [ "10.0.0.2/32" ];
        }
      ];
    };
  };

  systemd.services =
    builtins.listToAttrs
      (map
        (k: {
          name = "wireguard-${k}";
          value = { serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ]; };
        })
        (builtins.attrNames config.networking.wireguard.interfaces))
    // {
      update-duckdns = {
        serviceConfig = {
          Type = "oneshot";
          SupplementaryGroups = [ config.users.groups.keys.name ];
        };
        # This is just so the secret doesn't show up in my (public) repo -- if
        # somebody has local access to my system, them being able to update my
        # DuckDNS IP will be the least of my worries.
        script = ''
          echo url="https://www.duckdns.org/update?domains=scadrial&token=$(cat ${config.age.secrets.duckdns.path})" \
            | ${pkgs.curl}/bin/curl -K - 2>/dev/null
        '';
      };
    };

  systemd.timers.update-duckdns = {
    wantedBy = [ "timers.target" ];
    after = [ "home-manager-vin.service" "network.target" ];
    timerConfig = {
      Unit = "update-duckdns.service";
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
