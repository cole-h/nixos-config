{ pkgs, config, ... }:
{
  age.secrets.smb.file = ./smb-creds;

  fileSystems."/shares/media" = {
    device = "//192.168.1.25/media";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.smb.path}"

      # these options prevents hanging on network split
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
    ];
  };

  users.groups.downloads.gid = 947;
  users.users.downloads = {
    isSystemUser = true;
    group = "downloads";
    uid = 947;
    home = "/var/lib/torrent";
    createHome = true;
  };

  users.users.vin.extraGroups = [ "downloads" ];

  services.jellyfin = {
    enable = true;
    user = "downloads";
    group = "downloads";
  };

  networking.firewall.allowedTCPPorts = [
    8096 # jellyfin
    80
  ];

  networking.extraHosts = ''
    192.168.1.25 sonarr.local
    192.168.1.25 flood.local
    127.0.0.1 jellyfin.local
  '';

  services.nginx = {
    enable = true;
    virtualHosts =
      let
        onlyLan = ''
          allow 192.168.1.0/24;
          allow 192.168.122.0/24;
          allow 127.0.0.1;
          deny all;
        '';
      in
      {
        "jellyfin.local".locations."/" = {
          proxyPass = "http://127.0.0.1:8096/";
          extraConfig = onlyLan;
        };
      };
  };
}
