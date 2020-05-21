{ ... }:

{
  networking.hostName = "scadrial"; # Define your hostname.
  networking.hostId = "1bb11552"; # Required for ZFS.
  networking.useDHCP = false;
  networking.nameservers = [ "192.168.1.212" "8.8.8.8" ];
  networking.defaultGateway = "192.168.1.1";
  networking.interfaces.enp3s0.ipv4 = {
    addresses = [
      {
        address = "192.168.1.22";
        # address = "192.168.1.23";
        prefixLength = 24;
      }
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}
