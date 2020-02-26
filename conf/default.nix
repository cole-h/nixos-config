{
  imports = [
    # ./general.nix # stuff that doesn't warrant its own file

    # application-specific
    ./fish.nix # fish config
    ./mpv.nix # mpv config
    ./fonts.nix # contains fonts to import
    ./emacs.nix # doom-emacs setup
    ./neovim.nix # neovim config
    # TODO: activate
    # ./git.nix # git config
    # ./gpg.nix # GPG config
    # ./weechat.nix # weechat config
    # ./mpd.nix # mpd config
  ];
}
