{ doom
}:
final: prev:
let
  inherit (final)
    callPackage
    libsForQt5
    runCommand

    python3Packages
    ;
in
{
  # misc
  aerc = callPackage ./drvs/aerc { };
  fish = callPackage ./drvs/fish.nix { };
  foliate = callPackage ./drvs/foliate.nix { };
  git-crypt = callPackage ./drvs/git-crypt.nix { };
  iosevka-custom = callPackage ./drvs/iosevka/iosevka-custom.nix { };
  mdloader = callPackage ./drvs/mdloader { };
  sonarr = callPackage ./drvs/sonarr.nix { };
  bootloadHID = callPackage ./drvs/bootloadHID.nix { };

  redshift = callPackage ./drvs/redshift-wayland {
    inherit (python3Packages) python pygobject3 pyxdg wrapPython;
    withGeoclue = false;
    geoclue = null;
  };

  # small-ish overrides
  ripgrep = prev.ripgrep.override { withPCRE2 = true; };
  rofi = prev.rofi.override { plugins = [ final.rofi-emoji ]; };

  chatterino2 = prev.chatterino2.overrideAttrs ({ patches ? [ ], ... }: {
    # https://github.com/Chatterino/chatterino2/pull/2192
    patches = patches ++ [
      (final.fetchpatch {
        url = "https://github.com/Chatterino/chatterino2/commit/78897785b14011f0b11942c1aa598e52ff12964c.patch";
        sha256 = "sha256-9UvhRcTg9Jcdp4Iwa0zIC7fCQPzX1+l+1uuOjXcgav8=";
      })
      (final.fetchpatch {
        url = "https://github.com/Chatterino/chatterino2/commit/7cb1aaf8eb36e12b82982bff1c85a5a751d6698a.patch";
        sha256 = "sha256-frwsL59NYSmfXv8N3x4YxR9ugl1cVSMAnZjl8fzOyuY=";
      })
    ];
  });

  wlroots = prev.wlroots.overrideAttrs ({ ... }: {
    src = final.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = "0.10.1";
      sha256 = "0j2lh9vc92zhn44rjbia5aw3y1rpgfng1x1h17lcvj5m4i6vj0pc";
    };
  });

  sway-unwrapped = prev.sway-unwrapped.overrideAttrs ({ ... }: {
    src = final.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = "1.4";
      sha256 = "11qf89y3q92g696a6f4d23qb44gqixg6qxq740vwv2jw59ms34ja";
    };
  });

  discord = runCommand "discord"
    { buildInputs = [ final.makeWrapper ]; }
    ''
      makeWrapper ${prev.discord}/bin/Discord $out/bin/discord \
        --set "GDK_BACKEND" "x11"
    '';

  passff-host = prev.passff-host.overrideAttrs ({ ... }: {
    patchPhase = ''
      sed -i 's@COMMAND = "pass"@COMMAND = "${final.pass-otp}/bin/pass"@' src/passff.py
    '';
  });

  # python2 GTFO my closure
  neovim = prev.neovim.override {
    withPython = false;
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
  };

  hydrus = prev.hydrus.overrideAttrs ({ ... }: {
    preFixup = ''
      makeWrapperArgs+=(
        "''${qtWrapperArgs[@]}"
        "--add-flags" "--db_dir ''${XDG_DATA_HOME:-\$HOME/.local/share}/hydrus/db"
      )
    '';
  });

  kakoune-unwrapped = prev.kakoune-unwrapped.overrideAttrs ({ patches ? [ ], ... }: {
    patches = patches ++ [
      ./keep-newlines-in-sh.patch
    ];

    src = final.fetchFromGitHub {
      owner = "mawww";
      repo = "kakoune";
      rev = "958a9431214dc4bece30aa30a8159e0bb8b5bbe7";
      sha256 = "sha256-KSFuM9WQxdUc7lFaDYGB9zZGOHuckto9SEd9cR7evKo=";
    };
  });

  # Flakes-based
  doom-emacs = callPackage ./drvs/doom-emacs.nix { src = doom; };
}
