{
  programs.fish.enable = true;
  programs.fish.loginShellInit = ''
    for p in (string split " " $NIX_PROFILES)
      fish_add_path --prepend --move $p/bin
    end
  '';

  # NOTE: Won't work after system updates; will need to re-apply nix-darwin
  # configuration.
  security.pam.enableSudoTouchIdAuth = true;
}
