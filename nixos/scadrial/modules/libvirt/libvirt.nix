{ config, pkgs, ... }:
{
  environment.systemPackages = [
    # with-appliance or else `libguestfs: error: cannot find any suitable libguestfs supermin`
    # `doas guestmount -a /dev/rpool/win10 -m /dev/sda4 --ro /mnt`
    # pkgs.libguestfs-with-appliance
  ];

  users.users.vin.extraGroups = [
    "libvirtd"
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
}
