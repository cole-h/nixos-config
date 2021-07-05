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
  foliate = callPackage ./drvs/foliate.nix { };
  git-crypt = callPackage ./drvs/git-crypt.nix { };
  iosevka-custom = callPackage ./drvs/iosevka/iosevka-custom.nix { };
  mdloader = callPackage ./drvs/mdloader { };
  sonarr = callPackage ./drvs/sonarr.nix { };
  bootloadHID = callPackage ./drvs/bootloadHID.nix { };

  # small-ish overrides
  ripgrep = prev.ripgrep.override { withPCRE2 = true; };
  rofi = prev.rofi.override { plugins = [ final.rofi-emoji ]; };

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

  element-desktop = runCommand "element-desktop"
    { buildInputs = [ final.makeWrapper ]; }
    ''
      makeWrapper ${prev.element-desktop}/bin/element-desktop $out/bin/element-desktop \
        --add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'
      ln -s ${prev.element-desktop}/share $out/share
    '';

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

  kakoune-unwrapped = prev.kakoune-unwrapped.overrideAttrs ({ ... }: {
    src = final.fetchFromGitHub {
      owner = "mawww";
      repo = "kakoune";
      rev = "ead12e11bdfc861c0f1decb9ff7e91582196fcfe";
      sha256 = "UpnYNpZN4YLk2T3P8CfdgW0I7UKEyEj2EPONfGXQhHM=";
    };
  });

  vscode = runCommand "vscode"
    { buildInputs = [ final.makeWrapper ]; }
    ''
      makeWrapper ${prev.vscode}/bin/code $out/bin/code \
        --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
      ln -s ${prev.vscode}/share $out/share
    '';

  wlroots = prev.wlroots.overrideAttrs ({ patches ? [ ], ... }: {
    patches = patches ++ [
      # fix hang due to "drmModeSetCursor failed" -- "DRM: Moving pinned object 00000000e0ba99fc!"
      # https://github.com/swaywm/wlroots/issues/2991
      (final.fetchpatch {
        name = "drm-fix-cursor.patch";
        url = "https://patch-diff.githubusercontent.com/raw/swaywm/wlroots/pull/3021.patch";
        sha256 = "QhBXTI4h9+pwJNJaXex5Q3vBme/IdvUjZ6BwsnQikng=";
      })
    ];
  });

  # Flakes-based
  doom-emacs = callPackage ./drvs/doom-emacs.nix { src = doom; };
}
