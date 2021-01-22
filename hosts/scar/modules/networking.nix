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
    nameservers = [ "192.168.1.212" "1.1.1.1" ];
  };
}
