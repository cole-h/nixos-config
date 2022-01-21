{
  imports =
    [
      ./networking.nix
      ./nix.nix
      ./samba.nix
      ./users.nix

      ./downloads
      ./wireguard
      ./zrepl
    ];
}
