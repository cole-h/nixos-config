{ config, lib, pkgs, ... }:

{
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 445 139 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];

  services.samba = {
    enable = true;
    securityType = "user";

    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user
      #use sendfile = yes
      #max protocol = smb2
      hosts allow = 192.168., localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';

    shares = {
      public = {
        path = "/media";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "vin";
        "force group" = "users";
      };
    };
  };
}
