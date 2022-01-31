{
  imports = [
    # modules that configure something
    ./nix.nix
    ./misc.nix

    # modules that provide something
    ./mullvad-vpn.nix
    ./qbittorrent.nix
  ];
}
