{ pkgs, ... }:
{
  programs.fish.interactiveShellInit = ''
    source ${./iterm2_fish_integration.fish}
  '';
}
