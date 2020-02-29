{ config, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      gitAndTools.delta # better looking diffs
      git-crypt # store secrets [overlays]
    ];

    # file.".gitexclude".text = ''
    #   .gdb_history
    # '';
  };

  xdg.configFile = {
    "git/gitauth.inc".source = ./gitauth.inc;
    # "git/gitexcludes".text = ''
    "git/ignore".text = ''
      .gdb_history
    '';
  };

  programs.git = with pkgs; {
    enable = true;
    package = gitAndTools.gitFull;

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

      diff."nodiff".command = "${coreutils}/bin/true";

      core = {
        # excludesfile = "${config.xdg.configHome}/git/gitexcludes";
        pager = "${gitAndTools.delta}/bin/delta --dark --width=variable";
      };

      url = {
        "https://github.com/".insteadOf = ''"gh:"'';
        "ssh://git@github.com".pushInsteadOf = ''"gh:"'';
      };
    };
  };
}
