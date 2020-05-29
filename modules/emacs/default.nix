{ config, pkgs, ... }:
let
  # emacsGit # from emacs-overlay; [overlays]
  emacsPkg = pkgs.emacs26;

  em = pkgs.writeShellScriptBin "em" ''
    case "$1" in
         -*)
          exec ${emacsPkg}/bin/emacsclient "$@"
    esac

    # Checks if there's a frame open
    ${emacsPkg}/bin/emacsclient --no-wait --eval "(if (> (length (frame-list)) 1) 't)" 2> /dev/null | grep t &> /dev/null

    if [[ "$?" -eq 1 ]]; then
      exec ${emacsPkg}/bin/emacsclient --no-wait --quiet --create-frame "$@" --alternate-editor=""
    else
      exec ${emacsPkg}/bin/emacsclient --no-wait --quiet "$@"
    fi
  '';

  emn = pkgs.writeShellScriptBin "emn" ''
    exec ${emacsPkg}/bin/emacsclient --no-wait --quiet --create-frame "$@" --alternate-editor=""
  '';
in
{
  # Emacs 27+ supports the XDG Base Directory specification, so drop doom into
  # $XDG_CONFIG_HOME/emacs
  xdg.configFile."emacs".source = "${pkgs.doom-emacs}/share/doom-emacs";

  home = {
    packages = with pkgs; [
      doom-emacs # for `doom sync` and `doom update`; [drvs]
      emacsPkg # [drvs]
      em
      emn
      gnutls

      ## Module dependencies
      # :checkers spell
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      # :checkers grammar
      languagetool
      # :tools editorconfig
      editorconfig-core-c # per-project style config
      # :tools lookup & :lang org +roam
      sqlite
      # :lang cc
      ccls
      # :lang latex & :lang org (latex previews)
      texlive.combined.scheme-medium
      # :input japanese
      # cmigemo
      # :lang sh
      shellcheck
      # :lang python
      python3
      black
      # :lang markdown
      discount
    ];

    sessionVariables = {
      # Separate doom-emacs and its local things so updating doesn't wipe out
      # straight packages and such.
      DOOMLOCALDIR = "${config.xdg.dataHome}/doom-local";

      # Don't want to have to `home-manager switch` every time I change something,
      # so don't add it to the store.
      DOOMDIR = toString ./config;
    };
  };

  systemd.user = {
    services = {
      emacs = {
        Unit = {
          Description = "emacs";
          Documentation = [ "man:emacs(1)" ];
        };

        Service = {
          Type = "simple";
	  # ExecStartPre = "${doom-emacs}/bin/doom sync";
          ExecStart = "${emacsPkg}/bin/emacs --fg-daemon";
          Restart = "on-failure";
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
