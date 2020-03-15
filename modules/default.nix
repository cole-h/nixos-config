{
  imports = [
    ./fish.nix # fish config
    ./mpv.nix # mpv config
    ./fonts.nix # fonts I like :)
    ./emacs.nix # doom + emacs setup
    ./neovim.nix # neovim config
    ./mpd.nix # mpd config

    ./git # git config
    ./weechat # weechat config
    # TODO: activate
    ./wayland # sway, etc config
    # ./gpg.nix # GPG config
    # ./rust # rust-related
  ];
}
