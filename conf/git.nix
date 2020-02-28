# TODO: git-crypt, vault, transcrypt
{ config, pkgs, ... }:

{
  home = {
    packages = [ pkgs.gitAndTools.delta ];
    file.".gitexclude".text = ".gdb_history";
  };

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

    userEmail = "cole.e.helbling@outlook.com";
    userName = "Cole Helbling";
    signing = {
      key = "68B80D57B2E54AC3EC1F49B0B37E0F2371016A4C";
      signByDefault = true;
    };

    includes = [
      # includes github auth token, etc
      { path = "${config.xdg.configHome}/git/gitauth.inc"; }
    ];

    extraConfig = {
      git.autocrlf = "input";
      tag.forceSignAnnotated = true;

      diff."nodiff".command = "${pkgs.coreutils}/bin/true";

      core = {
        excludesfile = "${config.xdg.configHome}/git/gitexcludes";
        pager = "${pkgs.gitAndTools.delta}/bin/delta --dark --width=variable";
      };

      url = {
        "https://github.com/".insteadOf = ''"gh:"'';
        "ssh://git@github.com".pushInsteadOf = ''"gh:"'';
        # "https://aur.archlinux.org/".insteadOf = "aur:";
        # "ssh://aur@aur.archlinux.org/".pushInsteadOf = "aur:";
      };
    };
  };
}
