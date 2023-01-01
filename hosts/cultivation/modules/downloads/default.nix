{ pkgs, ... }:
{
  imports = [
    ./sonarr.nix
    ./torrent.nix
  ];

  users.groups.downloads.gid = 947;
  users.users.downloads = {
    isSystemUser = true;
    group = "downloads";
    uid = 947;
    home = "/var/lib/torrent";
    createHome = true;
  };

  users.users.slammer.extraGroups = [ "downloads" ];

  networking.firewall.allowedTCPPorts = [
    80
  ];

  services.nginx.enable = true;
  services.mullvad.enable = true;

  # this machine is headless; I always need to be able to SSH into it.
  systemd.services."mullvad-daemon".postStart = ''
    while ! ${pkgs.mullvad}/bin/mullvad status >/dev/null; do sleep 1; done
    ${pkgs.mullvad}/bin/mullvad lan set allow
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
