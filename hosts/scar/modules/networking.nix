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

    firewall = {
      # Needed for Mullvad: https://github.com/NixOS/nixpkgs/issues/113589
      checkReversePath = "loose";

      allowedTCPPorts = [
        53 # adguardhome dns
        80
      ];

      allowedUDPPorts = [
        53 # adguardhome dns
      ];
    };
  };

  # https://tailscale.com/kb/1063/install-nixos
  services.tailscale.enable = true;

  services.adguardhome = {
    enable = true;
    openFirewall = true;
  };

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
