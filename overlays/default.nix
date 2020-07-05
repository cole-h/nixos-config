final: super:
let
  inherit (final)
    callPackage
    libsForQt5
    runCommand
    pkgs
    lib
    enableDebugging

    python3Packages
    ;

  sources = import ../nix/sources.nix;
  naersk = callPackage sources.naersk { };
  # nixops = (import sources.nixops).defaultPackage.${builtins.currentSystem};
  nixops = (import ~/workspace/vcs/nixops).defaultPackage.${builtins.currentSystem};

  mozilla = import sources.nixpkgs-mozilla final super;
in
{
  inherit (mozilla) latest;

  passrs = callPackage ~/workspace/langs/rust/passrs { };

  # misc
  bemenu = callPackage ../drvs/bemenu.nix { };
  chatterino2 = libsForQt5.callPackage ../drvs/chatterino2.nix { };
  doom-emacs = callPackage ../drvs/doom-emacs.nix { };
  fish = callPackage ../drvs/fish.nix { };
  foliate = callPackage ../drvs/foliate.nix { };
  git-crypt = callPackage ../drvs/git-crypt.nix { };
  gsfonts = callPackage ../drvs/gsfonts.nix { };
  iosevka-custom = callPackage ../drvs/iosevka/iosevka-custom.nix { };
  sonarr = callPackage ../drvs/sonarr.nix { };

  alacritty = callPackage ../drvs/alacritty.nix {
    inherit (naersk) buildPackage;
  };

  hydrus = callPackage ../drvs/hydrus.nix {
    qtbase = final.qt5.qtbase;
  };

  redshift-wayland = callPackage ../drvs/redshift-wayland {
    inherit (python3Packages) python pygobject3 pyxdg wrapPython;
    withGeoclue = false;
    geoclue = null;
  };

  # FIXME: pinning is broken because default.nix uses `builtins.fetchGit ./.`
  nixops = nixops.overrideAttrs ({ ... }: {
    preBuild = "substituteInPlace nixops/__main__.py --replace '@version@' '2.0-local'";
    # preBuild = "substituteInPlace nixops/__main__.py --replace '@version@' '2.0-${sources.nixops.rev}'";
  });

  # small-ish overrides
  ripgrep = super.ripgrep.override { withPCRE2 = true; };
  rofi = super.rofi.override { plugins = [ final.rofi-emoji ]; };
  aerc = super.aerc.override { notmuch = null; };

  kakoune = super.kakoune.override {
    configure.plugins = with pkgs.kakounePlugins; [
      kak-powerline
      kak-auto-pairs
      kak-vertical-selection
      kak-buffers
    ];
  };

  discord = runCommand "discord"
    { buildInputs = [ final.makeWrapper ]; }
    ''
      makeWrapper ${super.discord}/bin/Discord $out/bin/discord \
        --set "GDK_BACKEND" "x11"
    '';

  passff-host = super.passff-host.overrideAttrs ({ ... }: {
    patchPhase = ''
      sed -i 's@COMMAND = "pass"@COMMAND = "${final.pass-otp}/bin/pass"@' src/passff.py
    '';
  });

  # https://gsc.io/content-addressed/73a9d19d65beca359dbf7f3f8f11f87f6bb227c364f8e36d7915ededde275bf4.nix
  # Thanks Graham
  emacsWayland =
    enableDebugging (
      final.emacs26.overrideAttrs (
        { buildInputs, nativeBuildInputs ? [ ], configureFlags ? [ ], ... }:
        let
          pname = "emacs-pgtk";
          version = "28.0.50";
        in
        {
          name = "${pname}-${version}";

          src = lib.cleanSource ../drvs/pgtk-emacs;

          patches = [ ];
          buildInputs = buildInputs ++ [ final.wayland final.wayland-protocols ];
          nativeBuildInputs = nativeBuildInputs ++ [ final.autoreconfHook final.texinfo ];

          configureFlags = configureFlags ++ [ "--without-x" "--with-cairo" "--with-modules" ];
        }
      )
    );

  hm-news = pkgs.writeShellScriptBin "hm-news" ''
    doNews() {
      local newsReadIdsFile="$HOME/.local/share/home-manager/news-read-ids"

      touch "$newsReadIdsFile"

      . $(nix-build --no-out-link \
                    '${sources.home-manager}/home-manager/home-manager.nix' \
                    -A newsInfo \
                    --arg check false \
                    --argstr confPath "${pkgs.writeText "home.nix" "{}"}" \
                    --argstr newsReadIdsFile "$newsReadIdsFile" 2>/dev/null)

      if [[ $newsNumUnread != 0 ]]; then
        $PAGER "$newsFileAll"

        if [[ -s "$newsUnreadIdsFile" ]]; then
            cat "$newsUnreadIdsFile" >> "$newsReadIdsFile"
        fi
      else
        echo No news
      fi
    }

    doNews
  '';
}
