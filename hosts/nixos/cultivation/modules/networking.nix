{ ... }:
let
  interface = "eth0";
in
{
  networking.useNetworkd = true;
  networking.useDHCP = false;

  systemd.network.wait-online.anyInterface = true;

  networking = {
    hostId = "31dfb58b"; # for zfs
    usePredictableInterfaceNames = false;
    interfaces.${interface}.ipv4.addresses = [
      {
        address = "192.168.1.55";
        prefixLength = 24;
      }
    ];
    defaultGateway.address = "192.168.1.1";
    defaultGateway.interface = interface;
    nameservers = [ "8.8.8.8" ];
  };

  # https://tailscale.com/kb/1063/install-nixos
  services.tailscale.enable = true;
}
