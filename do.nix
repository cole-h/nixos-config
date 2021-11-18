# Configuration for installing NixOS on a DigitalOcean droplet, using
# https://nixos.wiki/wiki/Install_NixOS_on_a_Server_With_a_Different_Filesystem
# !!!: Needs 4GB RAM droplet for kexec; can be downsized afterwards.
{ channels
}:
let
  system = "x86_64-linux";
  do = import "${channels.pkgs}/nixos" {
    inherit system;
    configuration = ({ pkgs, config, lib, modulesPath, ... }:
      {
        imports =
          [
            (modulesPath + "/installer/netboot/netboot-minimal.nix")
          ];

        ##### https://github.com/cleverca22/nix-tests/blob/5ace3327599c7121ac517f30ac291e948158fd3a/kexec/kexec.nix
        system.build = rec {
          image = pkgs.runCommand "image" { buildInputs = [ pkgs.nukeReferences ]; } ''
            mkdir $out
            cp ${config.system.build.kernel}/bzImage $out/kernel
            cp ${config.system.build.netbootRamdisk}/initrd $out/initrd
            echo "init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init ${toString config.boot.kernelParams}" > $out/cmdline
            nuke-refs $out/kernel
          '';
          kexec_script = pkgs.writeTextFile {
            executable = true;
            name = "kexec-nixos";
            text = ''
              #!${pkgs.stdenv.shell}
              export PATH=${pkgs.kexectools}/bin:${pkgs.cpio}/bin:$PATH
              set -x
              set -e
              cd $(mktemp -d)
              pwd
              mkdir initrd
              pushd initrd
              if [ -e /ssh_pubkey ]; then
                cat /ssh_pubkey >> authorized_keys
              fi
              find -type f | cpio -o -H newc | gzip -9 > ../extra.gz
              popd
              cat ${image}/initrd extra.gz > final.gz

              kexec -l ${image}/kernel --initrd=final.gz --append="init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init ${toString config.boot.kernelParams}"
              sync
              echo "executing kernel, filesystems will be improperly umounted"
              kexec -e
            '';
          };
        };
        boot.initrd.postMountCommands = ''
          mkdir -p /mnt-root/root/.ssh/
          cp /authorized_keys /mnt-root/root/.ssh/
        '';
        system.build.kexec_tarball = pkgs.callPackage "${modulesPath}/../lib/make-system-tarball.nix" {
          storeContents = [
            { object = config.system.build.kexec_script; symlink = "/kexec_nixos"; }
          ];
          contents = [ ];
        };
        #####

        nix.package = pkgs.nixUnstable;

        security.doas.enable = true;

        environment.systemPackages = with pkgs;
          [
            git
            kakoune
            htop
          ];

        systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh vin@scadrial"
        ];

        boot.supportedFilesystems = [ "zfs" ];
        boot.loader.grub.enable = false;
        boot.kernelParams = [
          "net.ifnames=0"
          "console=ttyS0,115200" # allows certain forms of remote access, if the hardware is setup right
          "panic=30"
          "boot.panic_on_fail" # reboot the machine upon fatal boot issues
        ];

        networking.hostName = "kexec";

        networking = {
          defaultGateway = "XXX.XXX.XXX.X";
          # Use google's public DNS server
          nameservers = [ "8.8.8.8" ];
          interfaces.eth0.ipv4.addresses = [{
            address = "XXX.XXX.XXX.XXX";
            prefixLength = 20;
          }];
        };
      });
  };
in
do.config.system.build.kexec_tarball
