{ passrs
, doom
, alacrittySrc
, naersk
}:
final: prev:
let
  inherit (final)
    callPackage
    libsForQt5
    runCommand

    python3Packages
    ;

  naerskLib = callPackage naersk { };
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

  hydrus = callPackage ./drvs/hydrus.nix {
    inherit (final.qt5) qtbase;
  };

  redshift = callPackage ./drvs/redshift-wayland {
    inherit (python3Packages) python pygobject3 pyxdg wrapPython;
    withGeoclue = false;
    geoclue = null;
  };

  # small-ish overrides
  ripgrep = prev.ripgrep.override { withPCRE2 = true; };
  rofi = prev.rofi.override { plugins = [ final.rofi-emoji ]; };

  # inherit (wayland) sway-unwrapped wlroots;
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

  kakoune = prev.kakoune.override {
    configure.plugins = with final.kakounePlugins;
      [
        kak-powerline
        kak-auto-pairs
        kak-vertical-selection
        kak-buffers
      ];
  };

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

  # Flakes-based
  inherit passrs;

  doom-emacs = callPackage ./drvs/doom-emacs.nix { src = doom; };

  alacritty = callPackage ./drvs/alacritty.nix {
    inherit (naerskLib) buildPackage;
    src = alacrittySrc;
  };
}
