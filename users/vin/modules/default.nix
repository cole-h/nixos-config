{
  imports =
    [
      ./fish.nix # fish config
      ./gpg.nix # GPG config
      ./mail.nix # maildir config
      ./mpd.nix # mpd config
      ./mpv.nix # mpv config
      ./neovim.nix # neovim config
      ./rust.nix # rust-related
      ./tmux.nix # tmux config

      ./emacs # doom + emacs setup
      ./git # git config
      ./kakoune # kakoune setup
      ./wayland # sway, etc config
      ./weechat # weechat config
    ];
}
