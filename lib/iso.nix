# Configuration for (re)installing NixOS.
{ inputs
, system
}:
let
  iso = import "${inputs.nixpkgs}/nixos" {
    inherit system;
    configuration = ({ pkgs, lib, modulesPath, ... }: {
      imports =
        [
          (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
          # (modulesPath + "/profiles/qemu-guest.nix")
        ];

      nix.package = pkgs.nixUnstable;
      nix.settings.extra-experimental-features = [ "nix-command flakes" ];

      security.doas.enable = true;

      environment.systemPackages = with pkgs;
        [
          git
          helix
          htop
        ];

      networking = {
        usePredictableInterfaceNames = false;
        interfaces.eth0.ipv4.addresses = [
          { address = "192.168.1.69"; prefixLength = 24; }
        ];
        defaultGateway = "192.168.1.1";
        nameservers = [ "1.1.1.1" ];
      };

      systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
      services.sshd.enable = true;
      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh vin@scadrial"
      ];
    });
  };
in
iso.config.system.build.isoImage
