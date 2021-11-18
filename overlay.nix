final: prev:
let
  inherit (final)
    callPackage
    runCommand
    ;
in
{
  # misc
  mdloader = callPackage ./drvs/mdloader { };
  bootloadHID = callPackage ./drvs/bootloadHID.nix { };

  # small-ish overrides
  ripgrep = prev.ripgrep.override { withPCRE2 = true; };
  rofi = prev.rofi.override { plugins = [ final.rofi-emoji ]; };

  # python2 GTFO my closure
  neovim = prev.neovim.override {
    withPython = false;
    withPython3 = false;
    withRuby = false;
    withNodeJs = false;
  };

  # larger overrides
  discord = prev.discord.overrideAttrs
    ({ buildInputs ? [ ], postFixup ? "", ... }: {
      buildInputs = buildInputs ++ [
        final.makeWrapper
      ];

      postFixup = postFixup + ''
        makeWrapper $out/bin/Discord $out/bin/discord \
          --set "GDK_BACKEND" "x11"
      '';
    });

  element-desktop = prev.element-desktop.overrideAttrs
    ({ buildInputs ? [ ], postFixup ? "", ... }: {
      buildInputs = buildInputs ++ [
        final.makeWrapper
      ];

      postFixup = postFixup + ''
        wrapProgram $out/bin/element-desktop \
          --add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'
      '';
    });

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

  vscode = prev.vscode.overrideAttrs
    ({ buildInputs ? [ ], postFixup ? "", ... }: {
      buildInputs = buildInputs ++ [
        final.makeWrapper
      ];

      postFixup = postFixup + ''
        wrapProgram $out/bin/code \
          --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
      '';
    });

  _1password-gui = prev._1password-gui.overrideAttrs
    ({ buildInputs ? [ ], postFixup ? "", ... }: {
      buildInputs = buildInputs ++ [
        final.makeWrapper
      ];

      postFixup = postFixup + ''
        wrapProgram $out/bin/1password \
          --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
      '';
    });
}
