{ pkgs, ... }:
{
  services.mullvad.enable = true;

  # this machine is headless; I always need to be able to SSH into it.
  systemd.services."mullvad-daemon".postStart = ''
    while ! ${pkgs.mullvad}/bin/mullvad status >/dev/null; do sleep 1; done
    ${pkgs.mullvad}/bin/mullvad lan set allow
    ${pkgs.mullvad}/bin/mullvad auto-connect set on
    ${pkgs.mullvad}/bin/mullvad lockdown-mode set on
  '';

  networking.firewall.extraCommands =
    let
      # Allow all tailscale IPs to connect, in case something goes REALLY wrong
      # and I can't access it over LAN.
      ts = pkgs.writeText "tailscale.rules" ''
        table inet excludeTraffic {
          chain excludeOutgoing {
            type route hook output priority -100; policy accept;
            ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }

          chain excludeIncoming {
            type filter hook input priority -100; policy accept;
            ip saddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }
        }
      '';
    in
    ''
      ${pkgs.nftables}/bin/nft -f ${ts}
    '';
}
