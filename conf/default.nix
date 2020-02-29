{
  imports = [
    # ./general.nix # stuff that doesn't warrant its own file

    # application-specific
    ./fish.nix # fish config
    ./mpv.nix # mpv config
    ./fonts.nix # contains fonts to import
    ./emacs.nix # doom-emacs setup
    ./neovim.nix # neovim config
    ./git # git config
    # TODO: activate
    # ./wayland # sway, etc config
    # ./gpg.nix # GPG config
    # ./weechat.nix # weechat config
    # ./mpd.nix # mpd config
    # ./rust # rust-related
  ];
}
