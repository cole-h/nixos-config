{ pkgs, config, ... }:
{
  age.secrets.smb.file = ./smb-creds;

  fileSystems."/shares/media" = {
    device = "//192.168.1.55/media";
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

  networking.extraHosts = ''
    192.168.1.55 sonarr.local
    192.168.1.55 jellyfin.local
  '';
}
