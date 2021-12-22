{ ... }:
{
  services.samba = {
    enable = false;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP  
      server string = smbnix  
      server role = standalone server
    '';
    shares = {
      media = {
        path = "/home/taln/test";
        comment = "scar shared media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        # NOTE: need to `doas smbpasswd -a username` to be able to log in
        "force user" = "taln";
        "force group" = "users";
      };
    };
  };
}
