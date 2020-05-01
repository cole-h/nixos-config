{ config, lib, pkgs, ... }:
let
  qemuHookFile = builtins.readFile (
    pkgs.fetchFromGitHub {
      owner = "PassthroughPOST";
      repo = "VFIO-Tools";
      rev = "db8e2ad263279d4fe356043ebbd87be9edbba1b6";
      sha256 = "0hv7d5jdrsp3x0hdzf5xbdnfjp8p1hyall17m63db5wv0jz79g69";
    } + "/libvirt_hooks/qemu"
  );
in
rec {
  prepare = ./qemu.d/windows10/prepare/begin/start.sh;
  release = ./qemu.d/windows10/release/end/revert.sh;
  started = ./qemu.d/windows10/started/begin/fifo.sh;

  # https://gist.github.com/WhittlesJr/a6de35b995e8c14b9093c55ba41b697c

  boot.kernelParams = "intel_iommu=on iommu=pt intel_iommu=igfx_off kvm.ignore_msrs=1";

  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu_kvm;
    # qemuVerbatimConfig?
    qemuOvmf = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # /etc/libvirt/hooks/qemu = https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu
  systemd.services.libvirtd = {
    path = with pkgs; [ coreutils procps rsync sway systemd utillinux ];
    preStart = ''
      rsync --chmod=755 --force -a ${qemuHookFile} /var/libvirt/hooks/
      rsync --chmod=755 --force -a ${prepare} /var/lib/libvirt/hooks/qemu.d/windows10/prepare/begin/
      rsync --chmod=755 --force -a ${release} /var/lib/libvirt/hooks/qemu.d/windows10/release/end/
      rsync --chmod=755 --force -a ${started} /var/lib/libvirt/hooks/qemu.d/windows10/started/begin/
    '';
  };
}
