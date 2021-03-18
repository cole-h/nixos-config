# All other filesystems will be automounted by ZFS.
{ ... }:
{
  fileSystems."/" =
    {
      device = "apool/r/local/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/nix" =
    {
      device = "apool/r/local/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
}
