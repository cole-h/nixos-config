{ ... }:
let
  interface = "enp6s0";
in
{
  networking.useNetworkd = true;
  networking.useDHCP = false;

  systemd.network.wait-online.anyInterface = true;

  networking.hostId = "1bb11552"; # Required for ZFS.
  networking.nameservers = [
    # "192.168.1.55"
    "8.8.8.8"
    "1.1.1.1"
    # "100.100.100.100" # tailscale
  ];
  # networking.search = [ "example.com.beta.tailscale.net" ];
  networking.defaultGateway.address = "192.168.1.1";
  networking.defaultGateway.interface = interface;
  networking.interfaces.${interface}.ipv4 = {
    addresses = [
      {
        address = "192.168.1.53";
        prefixLength = 24;
      }
    ];
  };

  networking.firewall.extraCommands = ''
    iptables -I FORWARD -i virbr0 -j ACCEPT
  '';

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22000 # syncthing
  ];

  networking.firewall.allowedUDPPorts = [
    21027 # syncthing
    51821
  ];
}
