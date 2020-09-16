# Configuration for (re)installing NixOS.
{ pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
      # (modulesPath + "/profiles/qemu-guest.nix")
    ];

  nix.package = pkgs.nixUnstable;

  environment.systemPackages = with pkgs;
    [
      git
      git-crypt
    ];

  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
    pinentryFlavor = "curses";
  };
}
