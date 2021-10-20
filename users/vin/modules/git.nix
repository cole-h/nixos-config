{ config, lib, pkgs, my, ... }:
let
  gdbinit = pkgs.fetchFromGitHub
    {
      owner = "cyrus-and";
      repo = "gdb-dashboard";
      rev = "b656071f4a2688045f3bd697bcb7885e99d89918";
      sha256 = "1rad11grnndh18bwa17m50i9bm2lnjhld8my9w0njsq6lq66myvx";
    } + "/.gdbinit";
in
{
  home.file.".gdbinit".source = gdbinit;

  xdg.configFile = {
    "git/ignore".text = ''
      .gdb_history
    '';
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    userEmail = "cole.e.helbling@outlook.com";
    userName = "Cole Helbling";

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

    extraConfig = {
      git.autocrlf = "input";
      tag.forceSignAnnotated = true;
      pull.rebase = true;
      push.default = "current";
      rebase.autoStash = true;
      sendemail.annotate = true;
      merge.conflictstyle = "diff3";
      init.defaultBranch = "main";
      absorb.maxStack = "100";

      diff."nodiff".command = "${pkgs.coreutils}/bin/true";

      url = {
        "https://github.com/".insteadOf = "gh:";
        "ssh://git@github.com".pushInsteadOf = "gh:";
        "https://gitlab.com/".insteadOf = "gl:";
        "ssh://git@gitlab.com".pushInsteadOf = "gl:";
      };
    };
  };
}




