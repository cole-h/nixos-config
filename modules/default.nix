{
  imports = [
    ./fish.nix # fish config
    ./fonts.nix # fonts I like :)
    ./gpg.nix # GPG config
    ./mpd.nix # mpd config
    ./mpv.nix # mpv config
    ./neovim.nix # neovim config
    ./scripts.nix # drop scripts into $HOME

    ./emacs # doom + emacs setup
    ./git # git config
    ./wayland # sway, etc config
    ./weechat # weechat config
    # ./rust.nix # rust-related
  ];
}
