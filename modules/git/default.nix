{ config, lib, pkgs, ... }:
let
  gitk = pkgs.writeText "gitk" (
    builtins.readFile (
      pkgs.fetchFromGitHub {
        owner = "dracula";
        repo = "gitk";
        rev = "b98afab830d49803e14b44ce330e3390360c7cd2";
        sha256 = "1cmirzrvk9y5n2yxjl7ghjspdpk4xqjx3in546prqjcfg7dl27ss";
      } + "/gitk"
    ) + ''
      set mainfont {{DejaVu Sans Mono} 10}
      set textfont {{JetBrains Mono} 10}
      set uifont {{DejaVu Sans Mono} 10 bold}
    ''
  );
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

    packages = with pkgs.gitAndTools; [
      git-crypt # store secrets; [overlays]
    ];

    activation = with lib; {
      gitk = hm.dag.entryAfter [ "linkGeneration" ] ''
        $DRY_RUN_CMD unlink \
          ${config.home.homeDirectory}/.config/git/gitk 2>/dev/null || true
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
          ${gitk} ${config.home.homeDirectory}/.config/git/gitk
      '';

      gitauth = hm.dag.entryAfter [ "linkGeneration" ] ''
        $DRY_RUN_CMD unlink \
          ${config.xdg.configHome}/git/gitauth.inc 2>/dev/null || true
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
          ${toString <vin/secrets/gitauth.inc>} \
          ${config.xdg.configHome}/git/gitauth.inc
      '';
    };
  };

  xdg.configFile = {
    "git/ignore".text = ''
      .gdb_history
    '';
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

      url = {
        "https://github.com/".insteadOf = ''"gh:"'';
        "ssh://git@github.com".pushInsteadOf = ''"gh:"'';
      };
    };
  };
}
