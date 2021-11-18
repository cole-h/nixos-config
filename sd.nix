# Configuration for (re)installing NixOS on aarch64.
{ pkgsFor
, inputs
}:
let
  system = "aarch64-linux";
  pkgs = pkgsFor inputs.nixpkgs system;
  buildImage = pkgs.callPackage "${inputs.aarch-images}/pkgs/build-image" { };

  image = (import "${inputs.nixpkgs}/nixos" {
    configuration = ({ pkgs, lib, modulesPath, ... }:
      {
        imports =
          [
            (modulesPath + "/installer/cd-dvd/sd-image-aarch64-new-kernel.nix")
          ];

        nix.package = pkgs.nixUnstable;
        nix.extraOptions = ''
          experimental-features = nix-command flakes
          builders-use-substitutes = true
        '';

        security.doas.enable = true;

        environment.systemPackages = with pkgs;
          [
            git
            git-crypt
            neovim
            kakoune
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

        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMcTaqUZSwv6YW8lx/JhsAZTdNSSC2fR8Pgk8woeFKh vin@scadrial"
        ];

        sdImage.compressImage = false;
        services.sshd.enable = true;
      });
    inherit system;
  }).config.system.build.sdImage;
in
pkgs.callPackage "${inputs.aarch-images}/images/rockchip.nix" {
  inherit buildImage;
  uboot = pkgs.ubootRock64;
  aarch64Image = pkgs.stdenv.mkDerivation {
    name = "sd";
    src = image;

    phases = [ "installPhase" ];
    noAuditTmpdir = true;
    preferLocalBuild = true;

    installPhase = "ln -s $src/sd-image/*.img $out";
  };
}
