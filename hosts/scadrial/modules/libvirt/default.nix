{ config, pkgs, ... }:
let
  # https://github.com/PassthroughPOST/VFIO-Tools/blob/0bdc0aa462c0acd8db344c44e8692ad3a281449a/libvirt_hooks/qemu
  # TODO: just pkgs.runCommand and sed the shebang away
  qemuHook = pkgs.stdenv.mkDerivation
    {
      name = "qemu-hook";
      src = pkgs.fetchFromGitHub {
        owner = "PassthroughPOST";
        repo = "VFIO-Tools";
        rev = "0bdc0aa462c0acd8db344c44e8692ad3a281449a";
        sha256 = "XAKMd8ZKhXuWT8pph+3QhATAl7FRt3swvHSK+SCXHuQ=";
      };

      installPhase = "cp libvirt_hooks/qemu $out";
    };
in
{
  environment.systemPackages = [
    # with-appliance or else `libguestfs: error: cannot find any suitable libguestfs supermin`
    # `doas guestmount -a /dev/rpool/win10 -m /dev/sda4 --ro /mnt`
    # pkgs.libguestfs-with-appliance
  ];

  users.users.vin.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  boot.kernelModules = [ "vfio-pci" ];
  boot.kernelParams = [
    "amd_iommu=on"
    "amd_iommu=pt"
    "iommu=pt"
    "kvm.ignore_msrs=1"
    "kvm.report_ignored_msrs=0"
    # "transparent_hugepage=never"
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  age.secrets.bios = {
    file = ./bios;
    path = "/var/lib/libvirt/vbios/patched-bios.rom";
  };

  systemd.services.libvirtd = {
    # scripts use binaries from these packages
    # NOTE: All these hooks are run with root privileges... Be careful!
    path =
      let
        env = pkgs.buildEnv {
          name = "qemu-hook-env";
          paths = with pkgs; [
            libvirt
            procps
            util-linux
            doas
            config.boot.kernelPackages.cpupower
            zfs
            ripgrep
            killall
          ];
        };
      in
      [ env ];

    preStart = ''
      [ -f /var/lib/libvirt/vbios/patched-bios.rom ] || exit 1

      mkdir -p /var/lib/libvirt/hooks
      mkdir -p /var/lib/libvirt/hooks/qemu.d/windows10/prepare/begin
      mkdir -p /var/lib/libvirt/hooks/qemu.d/windows10/release/end
      mkdir -p /var/lib/libvirt/hooks/qemu.d/windows10/started/begin

      ln -sf ${qemuHook} /var/lib/libvirt/hooks/qemu
      ln -sf ${./start.sh} /var/lib/libvirt/hooks/qemu.d/windows10/prepare/begin/start.sh
      ln -sf ${./revert.sh} /var/lib/libvirt/hooks/qemu.d/windows10/release/end/revert.sh
      ln -sf ${./fifo.sh} /var/lib/libvirt/hooks/qemu.d/windows10/started/begin/fifo.sh
    '';
  };
}
