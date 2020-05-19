{
  imports = [
    ./fish.nix # fish config
    ./fonts.nix # fonts I like :)
    ./gpg.nix # GPG config
    ./mpd.nix # mpd config
    ./mpv.nix # mpv config
    ./neovim.nix # neovim config
    ./rust.nix # rust-related
    ./scripts.nix # drop scripts into $HOME
    ./sound.nix # jack and cadence

    ./emacs # doom + emacs setup
    ./git # git config
    ./wayland # sway, etc config
    ./weechat # weechat config
  ];
}
