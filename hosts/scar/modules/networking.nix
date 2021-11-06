{ ... }:
{
  networking = {
    hostId = "31dfb58b"; # for zfs
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [
      {
        address = "192.168.1.25";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" ];
  };

  # https://tailscale.com/kb/1063/install-nixos
  services.tailscale.enable = true;
}
