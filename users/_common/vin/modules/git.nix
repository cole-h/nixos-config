{ config, lib, pkgs, my, ... }:
{
  xdg.configFile = {
    "git/ignore".text = ''
      .gdb_history
      .jj
    '';
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    includes = [
      # includes github auth token, etc
      { path = "gitauth.inc"; }
      # work stuff
      {
        condition = "gitdir:~/workspace/detsys/";
        contents = {
          user.email = "cole.helbling@determinate.systems";
        };
      }
    ];

    settings = {
      user.email = "cole.e.helbling@outlook.com";
      user.name = "Cole Helbling";

      tag.forceSignAnnotated = true;
      pull.rebase = true;
      push.default = "current";
      rebase.autoStash = true;
      sendemail.annotate = true;
      merge.conflictstyle = "diff3";
      init.defaultBranch = "main";
      absorb.maxStack = "100";
      commit.verbose = true;

      diff."nodiff".command = "${pkgs.coreutils}/bin/true";

      url = {
        "https://github.com/".insteadOf = "gh:";
        "git@github.com:".pushInsteadOf = "gh:";
        "https://gitlab.com/".insteadOf = "gl:";
        "git@gitlab.com:".pushInsteadOf = "gl:";
      };
    };
  };
}
