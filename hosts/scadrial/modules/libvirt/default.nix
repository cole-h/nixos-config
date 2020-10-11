{ pkgs, my, ... }:
let
  # https://github.com/PassthroughPOST/VFIO-Tools/blob/0bdc0aa462c0acd8db344c44e8692ad3a281449a/libvirt_hooks/qemu
  qemuHook = pkgs.writeShellScript "qemu" ''
    #
    # Author: Sebastiaan Meijer (sebastiaan@passthroughpo.st)
    #
    # Copy this file to /etc/libvirt/hooks, make sure it's called "qemu".
    # After this file is installed, restart libvirt.
    # From now on, you can easily add per-guest qemu hooks.
    # Add your hooks in /etc/libvirt/hooks/qemu.d/vm_name/hook_name/state_name.
    # For a list of available hooks, please refer to https://www.libvirt.org/hooks.html
    #

    GUEST_NAME="$1"
    HOOK_NAME="$2"
    STATE_NAME="$3"
    MISC="''${@:4}"

    BASEDIR="$(dirname $0)"

    HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"

    set -e # If a script exits with an error, we should as well.

    # check if it's a non-empty executable file
    if [ -f "$HOOKPATH" ] && [ -s "$HOOKPATH"] && [ -x "$HOOKPATH" ]; then
        eval \"$HOOKPATH\" "$@"
    elif [ -d "$HOOKPATH" ]; then
        while read file; do
            # check for null string
            if [ ! -z "$file" ]; then
              eval \"$file\" "$@"
            fi
        done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
    fi
  '';
in
{
  environment.systemPackages = [
    # with-appliance or else `libguestfs: error: cannot find any suitable libguestfs supermin`
    # commented out because it's too big to cache on hydra so we have to build it ourself...
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
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  systemd.services.libvirtd = {
    # scripts use binaries from these packages
    # NOTE: All these hooks are run with root privileges... Be careful!
    path = with pkgs; [ libvirt procps utillinux doas ];
    preStart = ''
      mkdir -p /var/lib/libvirt/vbios
      ln -sf ${my.secrets."patched-bios.rom"} /var/lib/libvirt/vbios/patched-bios.rom

      mkdir -p /var/lib/libvirt/hooks
      mkdir -p /var/lib/libvirt/hooks/qemu.d/windows10/prepare/begin
      mkdir -p /var/lib/libvirt/hooks/qemu.d/windows10/release/end
      mkdir -p /var/lib/libvirt/hooks/qemu.d/windows10/started/begin

      ln -sf ${qemuHook} /var/lib/libvirt/hooks/qemu
      ln -sf ${./start.sh} /var/lib/libvirt/hooks/qemu.d/windows10/prepare/begin/start.sh
      # ln -sf ${./alloc_hugepages.sh} /var/lib/libvirt/hooks/qemu.d/windows10/prepare/begin/alloc_hugepages.sh
      ln -sf ${./revert.sh} /var/lib/libvirt/hooks/qemu.d/windows10/release/end/revert.sh
      # ln -sf ${./dealloc_hugepages.sh} /var/lib/libvirt/hooks/qemu.d/windows10/release/end/dealloc_hugepages.sh
      ln -sf ${./fifo.sh} /var/lib/libvirt/hooks/qemu.d/windows10/started/begin/fifo.sh
    '';
  };
}
