{ config, lib, pkgs, ... }:
let
  gdbinit = pkgs.fetchFromGitHub {
    owner = "cyrus-and";
    repo = "gdb-dashboard";
    rev = "b656071f4a2688045f3bd697bcb7885e99d89918";
    sha256 = "1rad11grnndh18bwa17m50i9bm2lnjhld8my9w0njsq6lq66myvx";
  } + "/.gdbinit";
in
{
  home = {
    file.".gdbinit".source = gdbinit;

    packages = with pkgs; [
      git-crypt # store secrets; [overlays]
    ];
  };

  xdg.configFile = {
    "git/ignore".text = ''
      .gdb_history
    '';

    "git/gitauth.inc".source = config.lib.file.mkOutOfStoreSymlink config.my.secrets."gitauth.inc";
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
      { path = "gitauth.inc"; }
    ];

    extraConfig = {
      git.autocrlf = "input";
      tag.forceSignAnnotated = true;
      pull.rebase = true;
      push.default = "current";
      rebase.autoStash = true;
      sendemail.annotate = true;

      diff."nodiff".command = "${pkgs.coreutils}/bin/true";

      url = {
        "https://github.com/".insteadOf = "gh:";
        "ssh://git@github.com".pushInsteadOf = "gh:";
        # TODO: remove me after switching to NixOS
        "https://aur.archlinux.org/".insteadOf = "aur:";
        "ssh://aur@aur.archlinux.org/".pushInsteadOf = "aur:";

      };
    };
  };
}
