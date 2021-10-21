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
  iosevka-custom = callPackage ./drvs/iosevka/iosevka-custom.nix { };
  mdloader = callPackage ./drvs/mdloader { };
  sonarr = callPackage ./drvs/sonarr.nix { };
  bootloadHID = callPackage ./drvs/bootloadHID.nix { };
  fuzzel = callPackage ./drvs/fuzzel.nix { };

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
      rev = "689553c2e9b953a9d3822528d4ad858af95fb6a2";
      sha256 = "L9/nTwL24YPJrlpI0eyLmqhu1xfbKoi1IwrIeiwVUaE=";
    };
  });

  vscode = runCommand "vscode"
    { buildInputs = [ final.makeWrapper ]; }
    ''
      makeWrapper ${prev.vscode}/bin/code $out/bin/code \
        --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
      ln -s ${prev.vscode}/share $out/share
    '';

  _1password-gui = runCommand "1password-gui"
    { buildInputs = [ final.makeWrapper ]; }
    ''
      makeWrapper ${prev._1password-gui}/bin/1password $out/bin/1password \
        --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
      ln -s ${prev._1password-gui}/share $out/share
    '';
}
