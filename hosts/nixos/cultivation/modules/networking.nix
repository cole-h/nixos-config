{ config, ... }:
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
  services.tailscale.openFirewall = true;
  systemd.services.tailscaled.serviceConfig.ExecStartPost = "${config.services.tailscale.package}/bin/tailscale up --advertise-routes=192.168.1.0/24";

  # Enable IP forwarding for tailscale's subnet routing
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
