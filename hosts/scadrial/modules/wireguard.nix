{ config, pkgs, my, ... }:

{
  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp4s0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ config.networking.wireguard.interfaces.wg0.listenPort ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.0.0.1/24" ];
      listenPort = 1194;
      # TODO: nixus secrets for this
      privateKeyFile = "${my.secrets.wireguard}/private";

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o enp4s0 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.0/24 -o enp4s0 -j MASQUERADE
      '';

      peers = [
        {
          # Hathsin
          publicKey = "Nx3B53tK74nc909S0gM0sozUMZOVpAmkqsvyEo6VWSE=";
          # TODO: nixus secrets for this
          presharedKeyFile = "${my.secrets.wireguard}/psk";
          allowedIPs = [ "10.0.0.2/32" ];
        }
      ];
    };
  };

  systemd.timers.update-duckdns = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "update-duckdns.service";
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  systemd.services.update-duckdns = {
    serviceConfig.Type = "oneshot";
    # This is just so the secret doesn't show up in my (public) repo -- if
    # somebody has local access to my system, them being able to update my
    # DuckDNS IP will be the least of my worries.
    # TODO: nixus secrets for this
    script = ''
      echo url="https://www.duckdns.org/update?domains=scadrial&token=$(cat ${my.secrets.duckdns})" \
        | ${pkgs.curl}/bin/curl -K - 2>/dev/null
    '';
  };
}
