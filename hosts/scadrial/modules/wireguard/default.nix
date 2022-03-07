{ config, pkgs, lib, ... }:

{
  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp6s0";
  networking.nat.internalInterfaces = builtins.attrNames config.networking.wireguard.interfaces;
  networking.firewall.allowedUDPPorts =
    lib.mapAttrsToList
      (name: value: value.listenPort)
      config.networking.wireguard.interfaces;

  age.secrets = {
    wg0-priv = {
      file = ./priv;
    };

    wg0-psk = {
      file = ./psk;
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
        (builtins.attrNames config.networking.wireguard.interfaces));
}
