{
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";

    extraConfig = ''
      workgroup = COSMERE
      server string = smbnix
      server role = standalone server
      map to guest = bad user
    '';

    shares = {
      media = {
        path = "/shares/media";
        comment = "scar shared media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0771";
        "directory mask" = "0775";
        # NOTE: need to `doas smbpasswd -a username` to be able to log in
        "force user" = "taln";
        "force group" = "downloads";
      };
    };
  };
}
