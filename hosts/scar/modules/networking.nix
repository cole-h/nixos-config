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

  services.adguardhome = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [
    53 # adguardhome dns
    80
  ];

  networking.firewall.allowedUDPPorts = [
    53 # adguardhome dns
  ];

  services.nginx = {
    enable = true;
    virtualHosts =
      let
        onlyLan = ''
          allow 192.168.1.0/24;
          allow 127.0.0.1;
          deny all;
        '';
      in
      {
        "adguard.home".locations."/" = {
          proxyPass = "http://127.0.0.1:3000/";
          extraConfig = onlyLan;
        };
      };
  };
}
