{
  imports =
    [
      ./fish.nix # fish config
      ./git.nix # git config
      ./mail.nix # maildir config
      ./mpv.nix # mpv config
      ./music.nix # music config
      ./neovim.nix # neovim config
      ./rust.nix # rust-related
      ./tmux.nix # tmux config
      ./zsh.nix # zsh config

      # ./emacs # doom + emacs setup
      ./kakoune # kakoune setup
      ./wayland # sway, etc config
    ];
}
